import 'package:hijri/hijri_calendar.dart';
import '../models/islamic_occasion.dart';
import 'preferences_service.dart';

class OccasionService {
  final PreferencesService _prefs;

  OccasionService(this._prefs);

  /// Checks if any special Islamic occasion is currently active (first day).
  IslamicOccasion? getActiveOccasion() {
    final now = HijriCalendar.now();
    
    for (final occasion in IslamicOccasion.occasions) {
      if (now.hMonth == occasion.month && now.hDay == occasion.day) {
        return occasion;
      }
    }
    return null;
  }

  /// Determines if the greeting for the given occasion should be shown.
  /// It should be shown at most once every 24 hours during the occasion day.
  bool shouldShowGreeting(IslamicOccasion occasion) {
    final lastShown = _prefs.getLastGreetingShowTime(occasion.titleKey);
    if (lastShown == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastShown);
    return difference.inHours >= 24;
  }

  /// Marks an occasion greeting as shown.
  Future<void> markGreetingAsShown(IslamicOccasion occasion) async {
    await _prefs.saveGreetingShowTime(occasion.titleKey);
  }
}
