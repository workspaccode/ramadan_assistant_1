import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/services/adhan_alarm_service.dart';
import 'package:ramadan_assistant/core/services/background_task_service.dart';
import 'package:ramadan_assistant/core/services/dhikr_alarm_service.dart';
import 'package:ramadan_assistant/core/services/fcm_service.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/notification_service.dart';
import 'package:ramadan_assistant/core/services/prayer_service.dart';
import 'package:ramadan_assistant/core/services/dua_service.dart';
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
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

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
  await sl<DuaService>().init();
  await NotificationService.initialize();

  // Initialize Adhan Alarm Service (full-length Adhan audio)
  await AdhanAlarmService.init(
    navigatorKey: NotificationActionHandler.navigatorKey,
  );

  // Initialize Dhikr Alarm Service (full-length Reminder audio)
  await DhikrAlarmService.init(
    navigatorKey: NotificationActionHandler.navigatorKey,
  );

  BackgroundTaskService.initialize();
  if (!kDebugMode) {
    BackgroundTaskService.scheduleDailyUpdate();
  }

  // Initialize notification action handler
  await NotificationActionHandler.initialize();

  // Schedule today's prayer notifications - with error handling
  try {
    await BackgroundTaskService.scheduleNotificationsNow();
  } catch (e) {
    debugPrint('Error scheduling notifications: $e');
  }

  // Check for auto updates in background - with delay to prevent startup issues
  if (!kDebugMode) {
    Future.delayed(const Duration(minutes: 5), () {
      updateManager.checkAutoUpdates();
    });
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Add memory management for debug mode
  if (kDebugMode) {
    // Disable some heavy features in debug mode
    debugPrint('Running in debug mode - some features optimized');
  }

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
                    title: 'تَوب َتِي',
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

// ─── Overlay Entry Point ──────────────────────────────────────────

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const AzanOverlayWidget(),
    ),
  );
}

class AzanOverlayWidget extends StatefulWidget {
  const AzanOverlayWidget({super.key});

  @override
  State<AzanOverlayWidget> createState() => _AzanOverlayWidgetState();
}

class _AzanOverlayWidgetState extends State<AzanOverlayWidget> {
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is Map) {
        setState(() {
          _data = Map<String, dynamic>.from(event);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _data?['title'] ?? 'حان وقت الأذان';
    final body = _data?['body'] ?? 'أشهد أن لا إله إلا الله';
    final prayer = _data?['prayer'] ?? '';

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mosque_rounded, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (prayer.isNotEmpty)
                            Text(
                              'صلاة $prayer',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    Text(
                      body,
                      style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => FlutterOverlayWindow.closeOverlay(),
                            child: const Text('تجاهل', style: TextStyle(color: Colors.white38)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () => FlutterOverlayWindow.closeOverlay(),
                            child: const Text('تم', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
