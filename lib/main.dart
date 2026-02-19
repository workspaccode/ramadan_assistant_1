import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/services/background_task_service.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/notification_service.dart';
import 'package:ramadan_assistant/core/services/prayer_service.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/language_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/language_event.dart';
import 'package:ramadan_assistant/presentation/blocs/language_state.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_event.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_state.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/main_screen.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await setupServiceLocator();

  // Initialize Services
  await NotificationService.initialize();
  await requestAllPermissions();

  BackgroundTaskService.initialize();
  BackgroundTaskService.scheduleDailyUpdate();

  // Initialize notification action handler
  await NotificationActionHandler.initialize();

  // Schedule today's prayer notifications
  await BackgroundTaskService.scheduleNotificationsNow();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
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

Future<void> requestAllPermissions() async {
  var locationStatus = await Permission.location.status;
  if (!locationStatus.isGranted) {
    await Permission.location.request();
  }
  await NotificationService.requestPermissions();
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
                    key: ValueKey(
                      '${localeContext.locale}_${colorPaletteId}_$fontSizeMultiplier',
                    ),
                    title: 'Ramadan Assistant',
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.getTheme(
                      isDarkMode: false,
                      fontSizeMultiplier: fontSizeMultiplier,
                      colorPaletteId: colorPaletteId,
                    ),
                    darkTheme: AppTheme.getTheme(
                      isDarkMode: true,
                      fontSizeMultiplier: fontSizeMultiplier,
                      colorPaletteId: colorPaletteId,
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
