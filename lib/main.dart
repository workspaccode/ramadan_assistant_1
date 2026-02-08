import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ramadan_assistant/core/services/background_task_service.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/notification_service.dart';
import 'package:ramadan_assistant/core/services/prayer_service.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/language_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/language_event.dart';
import 'package:ramadan_assistant/presentation/blocs/language_state.dart';
import 'package:ramadan_assistant/presentation/blocs/prayer_times_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/prayer_times_event.dart';
import 'package:ramadan_assistant/presentation/blocs/settings_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/settings_event.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_event.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_state.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_event.dart';
import 'package:ramadan_assistant/presentation/screens/adhan_screen.dart';
import 'package:ramadan_assistant/presentation/screens/iqama_screen.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Services
  await NotificationService.initialize();
  await requestAllPermissions(); // Centralized permissions

  BackgroundTaskService.initialize();
  BackgroundTaskService.scheduleDailyUpdate();

  // Initialize notification action handler
  await NotificationActionHandler.initialize();

  // Schedule today's prayer notifications
  await BackgroundTaskService.scheduleNotificationsNow();

  final database = AppDatabase();
  final locationService = LocationService();
  final prayerService = PrayerService();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('ur')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      saveLocale: true,
      child: MyApp(
        database: database,
        locationService: locationService,
        prayerService: prayerService,
      ),
    ),
  );
}

Future<void> requestAllPermissions() async {
  // Request Notification Permission

  // Request Location Permission
  var locationStatus = await Permission.location.status;
  if (!locationStatus.isGranted) {
    await Permission.location.request();
  }
  await NotificationService.requestPermissions();
  // Request Ignore Battery Optimizations (Optional, for reliable alarms)
  // await Permission.ignoreBatteryOptimizations.request();
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  final LocationService locationService;
  final PrayerService prayerService;

  const MyApp({
    super.key,
    required this.database,
    required this.locationService,
    required this.prayerService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: database),
        RepositoryProvider.value(value: locationService),
        RepositoryProvider.value(value: prayerService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                PrayerTimesBloc(locationService, prayerService)
                  ..add(LoadPrayerTimes()),
          ),
          BlocProvider(
            create: (context) =>
                UmrahGuideBloc(database)..add(LoadUmrahProgress()),
          ),
          BlocProvider(
            create: (context) => SettingsBloc()..add(LoadSettings()),
          ),
          BlocProvider(create: (context) => ThemeBloc()..add(LoadTheme())),
          BlocProvider(
            create: (context) => LanguageBloc()..add(LoadLanguage()),
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<LanguageBloc, LanguageState>(
              listener: (context, state) {
                if (state is LanguageLoaded) {
                  final newLocale = Locale(state.languageCode);
                  if (context.locale != newLocale) {
                    context.setLocale(newLocale);
                  }
                }
              },
            ),
          ],
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              bool isDark = false;
              if (state is ThemeLoaded) {
                isDark = state.isDarkMode;
              }

              return Builder(
                builder: (localeContext) {
                  return MaterialApp(
                    title: 'Ramadan Assistant',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                    navigatorKey: NotificationActionHandler.navigatorKey,
                    localizationsDelegates: localeContext.localizationDelegates,
                    supportedLocales: localeContext.supportedLocales,
                    locale: localeContext.locale,
                    home: const MainScreen(),
                    routes: {
                      '/adhan': (context) {
                        final args =
                            ModalRoute.of(context)?.settings.arguments
                                as Map<String, dynamic>?;
                        return AdhanScreen(
                          prayerName: args?['prayer'] ?? 'Prayer',
                          iqamaDelayMinutes: args?['delay'] ?? 10,
                        );
                      },
                      '/iqama': (context) {
                        final args =
                            ModalRoute.of(context)?.settings.arguments
                                as String?;
                        return IqamaScreen(prayerName: args ?? 'Prayer');
                      },
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
