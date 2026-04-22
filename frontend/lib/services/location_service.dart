import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> checkPermission() =>
      Geolocator.checkPermission();

  Future<LocationPermission> requestLocationPermission() =>
      Geolocator.requestPermission();

  Future<Position?> getCurrentPosition() async {
    try {
      final permission = await checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      debugPrint('LocationService.getCurrentPosition error: $e');
      return null;
    }
  }

  Stream<Position> getPositionStream() => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      );

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) =>
      Geolocator.distanceBetween(lat1, lon1, lat2, lon2);

  static bool isInZone(
    double userLat,
    double userLon,
    double zoneLat,
    double zoneLon,
    double radiusMeters,
  ) =>
      calculateDistance(userLat, userLon, zoneLat, zoneLon) <= radiusMeters;
}
