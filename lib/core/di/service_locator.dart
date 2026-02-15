import 'package:get_it/get_it.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/prayer_service.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Services
  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<PrayerService>(() => PrayerService());

  // Notification Service is mostly static, but we can register it if needed
  // or keep it as is. For consistency, let's keep it static for now as it doesn't hold state in a way that needs injection,
  // but if we want to mock it later, injection is better.
}
