import 'package:get_it/get_it.dart';
import 'package:ramadan_assistant/core/persistence/document_store.dart';
import 'package:ramadan_assistant/core/persistence/drift_document_store.dart';
import 'package:ramadan_assistant/core/platform/feature_platform.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/prayer_service.dart';
import 'package:ramadan_assistant/core/utils/smart_update_manager.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/data/repositories/hadith_repository.dart';
import 'package:ramadan_assistant/data/services/hadith_service.dart';
import 'package:ramadan_assistant/core/services/dua_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  sl.registerLazySingleton<DocumentStore>(
    () => DriftDocumentStore(sl<AppDatabase>()),
  );
  sl.registerLazySingleton<FeaturePlatform>(() => FeaturePlatform());

  // Services
  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<PrayerService>(() => PrayerService());
  sl.registerLazySingleton<HadithService>(() => HadithService());
  sl.registerLazySingleton<SmartUpdateManager>(() => SmartUpdateManager());
  sl.registerLazySingleton<DuaService>(() => DuaService());

  // Repositories
  sl.registerLazySingleton<HadithRepository>(
    () => HadithRepository(sl<HadithService>()),
  );

  // Notification Service is mostly static, but we can register it if needed
  // or keep it as is. For consistency, let's keep it static for now as it doesn't hold state in a way that needs injection,
  // but if we want to mock it later, injection is better.
}
