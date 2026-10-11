// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';

void main() {
  group('Hijri calendar', () {
    test('returns a valid Gregorian date', () {
      final hijri = HijriCalendar.now();
      final gregorian = hijri.hijriToGregorian(
        hijri.hYear,
        hijri.hMonth,
        hijri.hDay,
      );

      expect(gregorian.year, greaterThan(2000));
      expect(gregorian.month, inInclusiveRange(1, 12));
      expect(gregorian.day, inInclusiveRange(1, 31));
    });

    test('month is within valid range', () {
      final hijri = HijriCalendar.now();
      expect(hijri.hMonth, inInclusiveRange(1, 12));
    });
  });

  group('Prayer calculations', () {
    test('computes prayer times for a known location', () {
      // Makkah coordinates, Umm Al-Qura method (as used by PrayerService)
      final coordinates = Coordinates(21.4225, 39.8262);
      final params = CalculationMethodParameters.ummAlQura();
      final prayerTimes = PrayerTimes(
        date: DateTime(2026, 3, 1),
        coordinates: coordinates,
        calculationParameters: params,
      );

      expect(prayerTimes.fajr, isNotNull);
      expect(prayerTimes.maghrib, isNotNull);
      expect(
        prayerTimes.fajr.isBefore(prayerTimes.maghrib),
        isTrue,
        reason: 'Fajr must occur before Maghrib',
      );
    });
  });
}
