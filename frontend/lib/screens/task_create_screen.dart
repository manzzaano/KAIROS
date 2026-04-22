import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../services/location_service.dart';
import '../utils/theme.dart';

class TaskCreateScreen extends StatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _minutesCtrl;
  int _energyLevel = 3;
  Position? _geoLocation;
  bool _loadingGeo = false;

  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _minutesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _minutesCtrl.dispose();
    super.dispose();
  }

  int get _priority => switch (_energyLevel) {
        1 || 2 => 1,
        3 => 2,
        _ => 3,
      };

  Future<void> _getLocation() async {
    setState(() => _loadingGeo = true);
    final position = await _locationService.getCurrentPosition();
    if (!mounted) return;
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PERMISO DE UBICACIÓN REQUERIDO')),
      );
    } else {
      setState(() => _geoLocation = position);
    }
    setState(() => _loadingGeo = false);
  }

  void _commit() {
    final title = _titleCtrl.text.trim();
    final minutes = int.tryParse(_minutesCtrl.text) ?? 0;
    if (title.isEmpty || minutes == 0) return;

    final provider = context.read<TaskProvider>();
    provider
        .createTask(
          title: title,
          priority: _priority,
          energy: _energyLevel,
          estimatedMinutes: minutes,
          latitude: _geoLocation?.latitude,
          longitude: _geoLocation?.longitude,
        )
        .then((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CONTRATO ESTABLECIDO')),
          );
          context.pop();
        })
        .catchError((_) {
          if (!mounted) return;
          final msg = context.read<TaskProvider>().error ?? 'Error desconocido';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: KairosColors.error600,
              content: Text(msg),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TaskProvider>().isLoading;
    final buttonColor =
        _energyLevel >= 4 ? KairosColors.error600 : KairosColors.neutral50;
    final buttonTextColor =
        _energyLevel >= 4 ? KairosColors.neutral50 : KairosColors.neutral900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CREAR CONTRATO',
          style: KairosTheme.mono(size: 11, letterSpacing: 2),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const _SectionLabel('CONTRATO'),
              const SizedBox(height: 12),
              TextField(
                controller: _titleCtrl,
                enabled: !isLoading,
                style: KairosTheme.serif(size: 32, weight: FontWeight.w300),
                decoration: InputDecoration(
                  hintText: '¿Cuál es tu contrato?',
                  hintStyle: KairosTheme.serif(
                      size: 32,
                      weight: FontWeight.w300,
                      color: KairosColors.neutral700),
                  border: InputBorder.none,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: KairosColors.neutral700, width: 0.5),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: KairosColors.neutral400, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _SectionLabel('ENERGÍA REQUERIDA'),
                  Text(
                    '$_energyLevel / 5',
                    style: KairosTheme.mono(
                        size: 10,
                        color: _energyLevel >= 4
                            ? KairosColors.error600
                            : KairosColors.neutral400,
                        letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 1,
                  activeTrackColor: KairosColors.neutral400,
                  inactiveTrackColor: KairosColors.neutral700,
                  thumbColor: KairosColors.neutral50,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 14),
                  overlayColor:
                      KairosColors.neutral700.withValues(alpha: 0.3),
                ),
                child: Slider(
                  value: _energyLevel.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: isLoading
                      ? null
                      : (v) => setState(() => _energyLevel = v.round()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (i) => Text(
                      '${i + 1}',
                      style: KairosTheme.mono(
                          size: 9,
                          color: _energyLevel == i + 1
                              ? KairosColors.neutral50
                              : KairosColors.neutral700,
                          letterSpacing: 0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const _SectionLabel('DURACIÓN'),
              const SizedBox(height: 12),
              TextField(
                controller: _minutesCtrl,
                enabled: !isLoading,
                style: KairosTheme.serif(size: 20),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Minutos',
                  hintStyle: KairosTheme.serif(
                      size: 20, color: KairosColors.neutral700),
                  suffixText: 'MIN',
                  suffixStyle: KairosTheme.mono(
                      size: 9,
                      color: KairosColors.neutral400,
                      letterSpacing: 1),
                  border: InputBorder.none,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: KairosColors.neutral700, width: 0.5),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: KairosColors.neutral400, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const SizedBox(height: 32),
              const _SectionLabel('ZONA (OPCIONAL)'),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: (isLoading || _loadingGeo) ? null : _getLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _geoLocation != null
                          ? KairosColors.neutral400
                          : KairosColors.neutral700,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      if (_loadingGeo)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 1,
                              color: KairosColors.neutral400),
                        )
                      else
                        Icon(
                          _geoLocation != null
                              ? Icons.location_on
                              : Icons.location_off_outlined,
                          size: 14,
                          color: _geoLocation != null
                              ? KairosColors.neutral50
                              : KairosColors.neutral700,
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _geoLocation == null
                              ? 'ESTABLECER ZONA'
                              : 'Lat: ${_geoLocation!.latitude.toStringAsFixed(4)}'
                                  '  Lon: ${_geoLocation!.longitude.toStringAsFixed(4)}',
                          style: KairosTheme.mono(
                              size: 9,
                              color: _geoLocation != null
                                  ? KairosColors.neutral50
                                  : KairosColors.neutral700,
                              letterSpacing: 1),
                        ),
                      ),
                      if (_geoLocation != null)
                        GestureDetector(
                          onTap: () => setState(() => _geoLocation = null),
                          child: const Icon(Icons.close,
                              size: 14, color: KairosColors.neutral700),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: FilledButton(
                    onPressed: isLoading ? null : _commit,
                    style: FilledButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonTextColor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: KairosColors.neutral900),
                          )
                        : Text(
                            'COMPROMETERSE',
                            style: KairosTheme.mono(
                                size: 12,
                                weight: FontWeight.w700,
                                color: buttonTextColor,
                                letterSpacing: 2),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: KairosTheme.mono(
          size: 9, color: KairosColors.neutral400, letterSpacing: 2),
    );
  }
}
