import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/persistence/auto_sync_service.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/services/background_task_service.dart';
import 'package:alarm/alarm.dart';
import 'package:ramadan_assistant/core/services/dua_service.dart';
import 'package:ramadan_assistant/core/services/fcm_service.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/notification_service.dart';
import 'package:ramadan_assistant/core/services/personal_alarm_service.dart';
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
import 'package:ramadan_assistant/presentation/screens/main_screen/main_screen.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_event.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/bloc/tasbih_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  sl<AutoSyncService>().start();
  runApp(const AppStartup());
}

/// Renders a first frame while plugins initialize and provides recovery if a
/// required service fails, rather than leaving the app on its native splash.
class AppStartup extends StatefulWidget {
  final Future<void> Function() initialize;
  final Widget child;

  const AppStartup({
    super.key,
    this.initialize = initializeAppServices,
    this.child = const MyApp(),
  });

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    try {
      await widget.initialize();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'app startup',
        ),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return widget.child;
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getLightTheme(const Locale('ar')),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('ثوابتي', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 24),
                        if (snapshot.hasError) ...[
                          const Text(
                            'تعذّر بدء التطبيق. حاول مرة أخرى.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => setState(() {
                              _initialization = _initialize();
                            }),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ] else ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          const Text('جارٍ تجهيز التطبيق…'),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> initializeAppServices() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await sl<DuaService>().init();
  await NotificationService.initialize();
  await Alarm.init();
  await _stopRetiredDhikrAlarms();
  await PersonalAlarmService.init(
    navigatorKey: NotificationActionHandler.navigatorKey,
  );
  await NotificationActionHandler.initialize();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Network access and optional scheduling cannot hold up the first screen.
  unawaited(_initializeOptionalServices());
}

/// Dhikr alarms (ids 1000..<1e9) were removed; stop any still scheduled by an
/// older version. Personal alarms use ids >= 1e9 and are left untouched.
Future<void> _stopRetiredDhikrAlarms() async {
  try {
    for (final alarm in await Alarm.getAlarms()) {
      if (alarm.id >= 1000 && alarm.id < 1000000000) {
        await Alarm.stop(alarm.id);
      }
    }
  } catch (error) {
    debugPrint('Retired dhikr alarm cleanup skipped: $error');
  }
}

Future<void> _initializeOptionalServices() async {
  final updateManager = sl<SmartUpdateManager>();
  unawaited(
    updateManager.initialize().catchError((Object error) {
      debugPrint('SmartUpdateManager initialization failed: $error');
    }),
  );

  unawaited(_initializePushMessaging());
  try {
    await BackgroundTaskService.initialize();
    if (!kDebugMode) {
      await BackgroundTaskService.scheduleDailyUpdate();
    }
  } catch (error, stackTrace) {
    debugPrint('Background scheduling unavailable: $error\n$stackTrace');
  }

  await BackgroundTaskService.scheduleDailyExtrasNow();

  if (!kDebugMode) {
    unawaited(
      Future<void>.delayed(const Duration(minutes: 5), () async {
        try {
          await updateManager.checkAutoUpdates();
        } catch (error, stackTrace) {
          debugPrint('Automatic update check failed: $error\n$stackTrace');
        }
      }),
    );
  }
}

Future<void> _initializePushMessaging() async {
  try {
    await FcmService.initialize();
    await FcmService.subscribeToTopic(
      'updates',
    ).timeout(const Duration(seconds: 10));
  } catch (error, stackTrace) {
    debugPrint('Push messaging unavailable: $error\n$stackTrace');
  }
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
          BlocProvider(create: (context) => TasbihBloc(sl<AppDatabase>())),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<LanguageBloc, LanguageState>(
              listener: (context, state) {
                if (state is LanguageLoaded) {
                  // Refresh prayer times with new locale for geocoding
                  context.read<PrayerTimesBloc>().add(
                    LoadPrayerTimes(locale: state.languageCode),
                  );
                }
              },
            ),
            BlocListener<ThemeBloc, ThemeState>(
              listener: (context, state) {
                // Theme is already handled by BlocBuilder in MaterialApp
              },
            ),
          ],
          child: BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, languageState) {
              final activeLocale = languageState is LanguageLoaded
                  ? Locale(languageState.languageCode)
                  : const Locale('ar');

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
                      activeLocale,
                      fontSizeMultiplier: fontSizeMultiplier,
                      paletteId: colorPaletteId ?? 'emerald',
                    ),
                    darkTheme: AppTheme.getDarkTheme(
                      activeLocale,
                      fontSizeMultiplier: fontSizeMultiplier,
                      paletteId: colorPaletteId ?? 'emerald',
                    ),
                    themeMode: isManualDarkMode
                        ? ThemeMode.dark
                        : ThemeMode.light,
                    navigatorKey: NotificationActionHandler.navigatorKey,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    locale: activeLocale,
                    home: Builder(
                      builder: (context) {
                        AppLocalizationsLookup.init(context);
                        return const MainScreen();
                      },
                    ),
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
