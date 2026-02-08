import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';

class PrayerService {
  PrayerTimes getPrayerTimes(
    Position position, {
    String? methodId,
    String? madhabId,
  }) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final params = _getMethod(methodId ?? 'muslimWorldLeague');
    params.madhab = _getMadhab(madhabId ?? 'shafi');

    final date = DateTime.now();
    return PrayerTimes(
      date: date,
      coordinates: coordinates,
      calculationParameters: params,
    );
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
