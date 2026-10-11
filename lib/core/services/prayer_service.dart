import 'dart:ui' show Locale;
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _logger = Logger();

class PrayerData {
  final PrayerTimes prayerTimes;
  final Position position;
  final String locationName;
  final String methodId;
  final String madhabId;

  PrayerData({
    required this.prayerTimes,
    required this.position,
    required this.locationName,
    required this.methodId,
    required this.madhabId,
  });
}

class PrayerService {
  PrayerService({this.geocodingTimeout = const Duration(seconds: 8)});
  final Duration geocodingTimeout;
  PrayerTimes getPrayerTimes(
    Position position, {
    String? methodId,
    String? madhabId,
  }) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final method = methodId ?? 'muslimWorldLeague';
    final params = _getMethod(method);
    params.madhab = _getMadhab(madhabId ?? 'shafi');

    _logger.d('PrayerService: method=$method, methodId=$methodId');

    // Umm Al-Qura: Add +30 min to Isha during Ramadan
    // Official Umm Al-Qura uses 120 min after Maghrib in Ramadan vs 90 min normally
    final hijri = HijriCalendar.now();
    _logger.d(
      'PrayerService: Hijri date=${hijri.hDay}/${hijri.hMonth}/${hijri.hYear}',
    );

    if (method == 'ummAlQura') {
      if (hijri.hMonth == 9) {
        // Ramadan
        params.adjustments[Prayer.isha] = 30;
        _logger.i('PrayerService: Applied Ramadan +30 min Isha adjustment');
      } else {
        _logger.d(
          'PrayerService: Not Ramadan (hMonth=${hijri.hMonth}), no Isha adjustment',
        );
      }
    } else {
      _logger.d('PrayerService: Not ummAlQura method, no Isha adjustment');
    }

    final date = DateTime.now();
    final prayerTimes = PrayerTimes(
      date: date,
      coordinates: coordinates,
      calculationParameters: params,
    );

    _logger.d(
      'PrayerService: Isha=${prayerTimes.isha.toLocal()}, Maghrib=${prayerTimes.maghrib.toLocal()}',
    );

    return prayerTimes;
  }

  Future<PrayerData> getCurrentPrayerData(
    Position position, {
    String? localeLanguageCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    String? methodId = prefs.getString('calculation_method');
    String? madhabId = prefs.getString('madhab');

    final language = ['ar', 'en', 'ur'].contains(localeLanguageCode)
        ? localeLanguageCode!
        : 'en';
    String locationName = lookupAppLocalizations(Locale(language)).unknown;
    String? country;
    try {
      if (localeLanguageCode != null) {
        await setLocaleIdentifier(localeLanguageCode).timeout(geocodingTimeout);
      }
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(geocodingTimeout);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [p.locality ?? p.subAdministrativeArea, p.country]
            .whereType<String>()
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();
        if (parts.isNotEmpty) locationName = parts.join(', ');
        country = p.country;
      }
    } catch (_) {}

    // Auto-detect calculation method if not set
    if (methodId == null && country != null) {
      methodId = getAutoMethodId(country);
      if (methodId != null) {
        await prefs.setString('calculation_method', methodId);
      }
    }

    final prayerTimes = getPrayerTimes(
      position,
      methodId: methodId,
      madhabId: madhabId,
    );

    return PrayerData(
      prayerTimes: prayerTimes,
      position: position,
      locationName: locationName,
      methodId: methodId ?? 'muslimWorldLeague',
      madhabId: madhabId ?? 'shafi',
    );
  }

  String? getAutoMethodId(String country) {
    country = country.toLowerCase();
    if (country.contains('egypt')) return 'egyptian';
    if (country.contains('saudi') || country.contains('makkah')) {
      return 'ummAlQura';
    }
    if (country.contains('dubai') || country.contains('emirates')) {
      return 'dubai';
    }
    if (country.contains('qatar')) return 'qatar';
    if (country.contains('kuwait')) return 'kuwait';
    if (country.contains('pakistan')) return 'karachi';
    if (country.contains('singapore')) return 'singapore';
    if (country.contains('usa') ||
        country.contains('canada') ||
        country.contains('america')) {
      return 'northAmerica';
    }
    return 'muslimWorldLeague';
  }

  CalculationParameters _getMethod(String methodId) {
    switch (methodId) {
      case 'egyptian':
        return CalculationMethodParameters.egyptian();
      case 'karachi':
        return CalculationMethodParameters.karachi();
      case 'ummAlQura':
        return CalculationMethodParameters.ummAlQura();
      case 'dubai':
        return CalculationMethodParameters.dubai();
      case 'qatar':
        return CalculationMethodParameters.qatar();
      case 'kuwait':
        return CalculationMethodParameters.kuwait();
      case 'singapore':
        return CalculationMethodParameters.singapore();
      case 'northAmerica':
        return CalculationMethodParameters.northAmerica();
      case 'muslimWorldLeague':
      default:
        return CalculationMethodParameters.muslimWorldLeague();
    }
  }

  Madhab _getMadhab(String madhabId) {
    switch (madhabId) {
      case 'hanafi':
        return Madhab.hanafi;
      case 'shafi':
      default:
        return Madhab.shafi;
    }
  }

  String getNextPrayer(PrayerTimes prayerTimes) {
    return prayerTimes.nextPrayer().name;
  }
}
