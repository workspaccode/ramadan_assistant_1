import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Location service with last-known-position caching.
///
/// The cached position is what background tasks (Workmanager daily prayer
/// scheduling) use, so the app never needs ACCESS_BACKGROUND_LOCATION — one of
/// the hardest permissions to get approved on Google Play.
class LocationService {
  static const String _latKey = 'cached_location_lat';
  static const String _lngKey = 'cached_location_lng';
  static const String _timestampKey = 'cached_location_timestamp';

  Future<Position> getCurrentLocation({bool requestPermission = true}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (requestPermission) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // A missing GPS fix should reach the screen's retry state instead of
    // leaving prayer times on a spinner indefinitely.
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        timeLimit: Duration(seconds: 20),
      ),
    );
    unawaited(_cachePosition(position));
    return position;
  }

  Future<void> _cachePosition(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_latKey, position.latitude);
      await prefs.setDouble(_lngKey, position.longitude);
      await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error caching position: $e');
    }
  }

  /// Last known position (from the last foreground location fix), or null if
  /// the app has never obtained a location. Used by background scheduling.
  Future<Position?> getCachedPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final lng = prefs.getDouble(_lngKey);
    if (lat == null ||
        lng == null ||
        !lat.isFinite ||
        !lng.isFinite ||
        lat < -90 ||
        lat > 90 ||
        lng < -180 ||
        lng > 180) {
      return null;
    }

    final timestampMs = prefs.getInt(_timestampKey) ?? 0;
    if (timestampMs < 0 ||
        timestampMs > DateTime.now().millisecondsSinceEpoch) {
      return null;
    }
    return Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
      isMocked: false,
    );
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }

  Future<Placemark?> getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 8));
      if (placemarks.isNotEmpty) {
        return placemarks.first;
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
    return null;
  }
}
