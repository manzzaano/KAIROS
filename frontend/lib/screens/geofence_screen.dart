import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/location_service.dart';
import '../utils/theme.dart';

const double _kZoneRadiusM = 500.0;

class GeofenceScreen extends StatefulWidget {
  const GeofenceScreen({super.key});

  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen> {
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _positionSub;

  Position? _currentPosition;
  bool _isInZone = false;
  bool _trackingEnabled = false;
  bool _permissionDenied = false;
  bool _serviceDisabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
    _initLocation();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final serviceOn = await _locationService.isLocationServiceEnabled();
    if (!serviceOn) {
      setState(() => _serviceDisabled = true);
      return;
    }

    var permission = await _locationService.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _locationService.requestLocationPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => _permissionDenied = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PERMISO DE UBICACIÓN REQUERIDO')),
        );
      }
    }
  }

  void _onTrackingToggle(bool value) {
    setState(() => _trackingEnabled = value);
    if (value) {
      _startTracking();
    } else {
      _positionSub?.cancel();
      _positionSub = null;
      setState(() {
        _currentPosition = null;
        _isInZone = false;
      });
    }
  }

  void _startTracking() {
    _positionSub = _locationService.getPositionStream().listen((position) {
      if (!mounted) return;
      final tasks = context.read<TaskProvider>().tasks;
      final inZone = tasks
          .where((t) => !t.completed && !t.abandoned && t.latitude != null)
          .any((t) => LocationService.isInZone(
                position.latitude,
                position.longitude,
                t.latitude!,
                t.longitude!,
                _kZoneRadiusM,
              ));
      setState(() {
        _currentPosition = position;
        _isInZone = inZone;
      });
    });
  }

  String _distanceLabel(Task task) {
    if (task.latitude == null || _currentPosition == null) return '–';
    final d = LocationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      task.latitude!,
      task.longitude!,
    );
    if (d < 50) return '0.0 km (aquí)';
    if (d < 1000) return '${d.toStringAsFixed(0)} m';
    return '${(d / 1000).toStringAsFixed(1)} km';
  }

  bool _taskIsHere(Task task) {
    if (task.latitude == null || _currentPosition == null) return false;
    return LocationService.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          task.latitude!,
          task.longitude!,
        ) <
        50;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final zoneTasks = provider.tasks
        .where((t) => !t.completed && !t.abandoned && t.latitude != null)
        .toList();

    final zoneColor =
        _isInZone ? KairosColors.neutral50 : KairosColors.error600;
    final zoneLabel = _isInZone ? '✓  DENTRO DE ZONA' : '✗  FUERA DE ZONA';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ZONAS DE TRABAJO',
          style: KairosTheme.mono(size: 11, letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ACTIVAR TRACKING',
                    style: KairosTheme.mono(
                        size: 9,
                        color: KairosColors.neutral400,
                        letterSpacing: 2),
                  ),
                  Switch(
                    value: _trackingEnabled,
                    onChanged: (_permissionDenied || _serviceDisabled)
                        ? null
                        : _onTrackingToggle,
                    activeThumbColor: KairosColors.neutral50,
                    activeTrackColor: KairosColors.neutral700,
                    inactiveThumbColor: KairosColors.neutral700,
                    inactiveTrackColor: KairosColors.neutral900,
                    trackOutlineColor: WidgetStateProperty.resolveWith(
                      (s) => s.contains(WidgetState.selected)
                          ? KairosColors.neutral400
                          : KairosColors.neutral700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: zoneColor.withValues(alpha: 0.4), width: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _serviceDisabled
                          ? '⚠  SERVICIO DE UBICACIÓN DESACTIVADO'
                          : _permissionDenied
                              ? '⚠  PERMISO DENEGADO'
                              : !_trackingEnabled
                                  ? '·  TRACKING DESACTIVADO'
                                  : _currentPosition == null
                                      ? '·  OBTENIENDO UBICACIÓN...'
                                      : zoneLabel,
                      style: KairosTheme.mono(
                          size: 11, color: zoneColor, letterSpacing: 2),
                    ),
                    if (_currentPosition != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}'
                        '  Lon: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                        style: KairosTheme.mono(
                            size: 8,
                            color: KairosColors.neutral700,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ],
                ),
              ),
              if (_trackingEnabled &&
                  _currentPosition == null &&
                  !_permissionDenied &&
                  !_serviceDisabled)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        color: KairosColors.neutral700,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              Center(
                child: _RadarMap(isInZone: _isInZone),
              ),
              const SizedBox(height: 32),
              Text(
                'TAREAS EN ZONA',
                style: KairosTheme.mono(
                    size: 9, color: KairosColors.neutral400, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              if (provider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: CircularProgressIndicator(
                        color: KairosColors.neutral700, strokeWidth: 1),
                  ),
                )
              else if (zoneTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'SIN TAREAS CON ZONA ASIGNADA',
                    style: KairosTheme.mono(
                        size: 9,
                        color: KairosColors.neutral700,
                        letterSpacing: 1),
                  ),
                )
              else
                for (final task in zoneTasks)
                  _TaskRow(
                    title: task.title,
                    distance: _distanceLabel(task),
                    isHere: _taskIsHere(task),
                  ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.title,
    required this.distance,
    required this.isHere,
  });
  final String title;
  final String distance;
  final bool isHere;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: KairosColors.neutral700, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: KairosTheme.serif(size: 15, weight: FontWeight.w300),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            distance,
            style: KairosTheme.mono(
              size: 9,
              color: isHere ? KairosColors.neutral50 : KairosColors.neutral400,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarMap extends StatelessWidget {
  const _RadarMap({required this.isInZone});
  final bool isInZone;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(280, 280),
      painter: _RadarPainter(isInZone: isInZone),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({required this.isInZone});
  final bool isInZone;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    final midR = outerR * 0.6;
    final innerR = outerR * 0.25;

    final borderPaint = Paint()
      ..color = KairosColors.neutral700
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final zoneFill = Paint()
      ..color = KairosColors.neutral700.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final crosshairPaint = Paint()
      ..color = KairosColors.neutral700.withValues(alpha: 0.4)
      ..strokeWidth = 0.5;

    canvas.drawCircle(center, innerR, zoneFill);
    canvas.drawCircle(center, midR, zoneFill);
    canvas.drawCircle(center, outerR, borderPaint);
    canvas.drawCircle(center, midR, borderPaint);
    canvas.drawCircle(center, innerR, borderPaint);

    canvas.drawLine(Offset(center.dx - outerR, center.dy),
        Offset(center.dx + outerR, center.dy), crosshairPaint);
    canvas.drawLine(Offset(center.dx, center.dy - outerR),
        Offset(center.dx, center.dy + outerR), crosshairPaint);

    for (var i = 1; i <= 4; i++) {
      final angle = (i * math.pi / 4) - math.pi / 8;
      canvas.drawLine(
        center,
        Offset(center.dx + math.cos(angle) * outerR,
            center.dy + math.sin(angle) * outerR),
        crosshairPaint,
      );
    }

    final dotPaint = Paint()
      ..color = isInZone ? KairosColors.neutral50 : KairosColors.error600
      ..style = PaintingStyle.fill;

    final dotOffset = isInZone
        ? center
        : Offset(center.dx + midR * 0.5, center.dy + midR * 0.3);

    canvas.drawCircle(dotOffset, 5, dotPaint);

    if (isInZone) {
      canvas.drawCircle(
        center,
        14,
        Paint()
          ..color = KairosColors.neutral50.withValues(alpha: 0.15)
          ..style = PaintingStyle.fill,
      );
    }

    final tp = TextPainter(
      text: TextSpan(
        text: 'TÚ',
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 8,
          color: isInZone ? KairosColors.neutral50 : KairosColors.error600,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(dotOffset.dx - tp.width / 2, dotOffset.dy + 10));
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.isInZone != isInZone;
}
