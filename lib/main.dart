import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/services/adhan_alarm_service.dart';
import 'package:ramadan_assistant/core/services/background_task_service.dart';
import 'package:ramadan_assistant/core/services/fcm_service.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/notification_service.dart';
import 'package:ramadan_assistant/core/services/prayer_service.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/core/utils/smart_update_manager.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/firebase_options.dart';
import 'package:ramadan_assistant/presentation/blocs/language_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/language_event.dart';
import 'package:ramadan_assistant/presentation/blocs/language_state.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_event.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_state.dart';
import 'package:ramadan_assistant/presentation/cubits/hadith/hadith_cubit.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/main_screen.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_event.dart';
import 'package:ramadan_assistant/presentation/screens/reminders_screen/bloc/reminders_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/bloc/tasbih_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_event.dart';
import 'package:tafsir_library/tafsir_library.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupServiceLocator();

  // Initialize Smart Update Manager
  final updateManager = sl<SmartUpdateManager>();
  await updateManager.initialize();

  // Initialize Firebase Cloud Messaging
  await FcmService.initialize();
  await FcmService.subscribeToTopic('updates');

  // Initialize Tafsir Library
  try {
    await TafsirLibrary.initialize();
  } catch (e) {
    debugPrint('Error initializing Tafsir Library: $e');
  }

  // Initialize Services
  await NotificationService.initialize();

  // Initialize Adhan Alarm Service (full-length Adhan audio)
  await AdhanAlarmService.init(
    navigatorKey: NotificationActionHandler.navigatorKey,
  );

  BackgroundTaskService.initialize();
  BackgroundTaskService.scheduleDailyUpdate();

  // Initialize notification action handler
  await NotificationActionHandler.initialize();

  // Schedule today's prayer notifications
  await BackgroundTaskService.scheduleNotificationsNow();

  // Check for auto updates in background
  updateManager.checkAutoUpdates();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('ur')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: sl<AppDatabase>()),
        RepositoryProvider.value(value: sl<LocationService>()),
        RepositoryProvider.value(value: sl<PrayerService>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                PrayerTimesBloc(sl<LocationService>(), sl<PrayerService>())
                  ..add(LoadPrayerTimes()),
          ),
          BlocProvider(create: (context) => ThemeBloc()..add(LoadTheme())),
          BlocProvider(
            create: (context) => LanguageBloc()..add(LoadLanguage()),
          ),
          BlocProvider(
            create: (context) => WirdBloc(sl())..add(LoadWirdProgress()),
          ),
          BlocProvider(create: (context) => TasbihBloc(sl<AppDatabase>())),
          BlocProvider(
            create: (context) =>
                RemindersBloc(sl<AppDatabase>())..add(LoadReminders()),
          ),
          BlocProvider(create: (context) => HadithCubit(sl())..loadHadiths()),
          
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<LanguageBloc, LanguageState>(
              listener: (context, state) {
                if (state is LanguageLoaded) {
                  final newLocale = Locale(state.languageCode);
                  if (context.locale != newLocale) {
                    context.setLocale(newLocale);
                    // Refresh prayer times with new locale for geocoding
                    context.read<PrayerTimesBloc>().add(
                      LoadPrayerTimes(locale: state.languageCode),
                    );
                  }
                }
              },
            ),
            BlocListener<ThemeBloc, ThemeState>(
              listener: (context, state) {
                // Theme is already handled by BlocBuilder in MaterialApp
              },
            ),
          ],
          child: Builder(
            builder: (localeContext) {
              return BlocBuilder<ThemeBloc, ThemeState>(
                builder: (themeContext, themeState) {
                  final fontSizeMultiplier = themeState is ThemeLoaded
                      ? themeState.fontSizeMultiplier
                      : 1.0;
                  final colorPaletteId = themeState is ThemeLoaded
                      ? themeState.colorPaletteId
                      : null;
                  final isManualDarkMode = themeState is ThemeLoaded
                      ? themeState.isDarkMode
                      : false;

                  return MaterialApp(
                    title: 'Ramadan Assistant',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.getLightTheme(
                      localeContext.locale,
                      fontSizeMultiplier: fontSizeMultiplier,
                      paletteId: colorPaletteId ?? 'emerald',
                    ),
                    darkTheme: AppTheme.getDarkTheme(
                      localeContext.locale,
                      fontSizeMultiplier: fontSizeMultiplier,
                      paletteId: colorPaletteId ?? 'emerald',
                    ),
                    themeMode: isManualDarkMode
                        ? ThemeMode.dark
                        : ThemeMode.light,
                    navigatorKey: NotificationActionHandler.navigatorKey,
                    localizationsDelegates: localeContext.localizationDelegates,
                    supportedLocales: localeContext.supportedLocales,
                    locale: localeContext.locale,
                    home: const MainScreen(),
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
