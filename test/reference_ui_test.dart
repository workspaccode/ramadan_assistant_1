import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/services/dua_service.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/language_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/bloc/tasbih_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/widgets/tasbih_content.dart';
import 'package:ramadan_assistant/presentation/screens/dhikr_screen/dhikr_screen.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen/bloc/settings_screen_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen/widgets/settings_screen_content.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_state.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/widgets/prayer_times_content.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

class _Tasbih extends Cubit<TasbihState> implements TasbihBloc {
  _Tasbih()
    : super(
        const TasbihCounting(
          count: 12,
          target: 33,
          currentDhikr: 'SubhanAllah',
        ),
      );
  @override
  void add(TasbihEvent event) {
    if (event is IncrementCounter) {
      emit(
        TasbihCounting(
          count: state.count + 1,
          target: state.target,
          currentDhikr: state.currentDhikr,
        ),
      );
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Settings extends Cubit<SettingsScreenState>
    implements SettingsScreenBloc {
  _Settings()
    : super(
        const SettingsScreenLoaded(
          calculationMethod: 'ummAlQura',
          madhab: 'shafi',
          fontSizeMultiplier: 1,
          colorPaletteId: 'emerald',
          country: 'السعودية',
          city: 'مكة المكرمة',
          appIcon: 'default',
          notificationsEnabled: true,
          hijriAdjustment: 0,
        ),
      );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final service = DuaService();
    await service.init();
    if (!sl.isRegistered<DuaService>()) {
      sl.registerSingleton<DuaService>(service);
    }
  });
  tearDownAll(() async {
    await sl.reset();
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Tawabti',
      packageName: 'app.tawabti',
      version: '2.0.6',
      buildNumber: '1',
      buildSignature: '',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (call) async => 1,
        );
    AppTabNavigation.index.value = 0;
  });
  for (final page in ['tasbih', 'dhikr', 'settings', 'prayers']) {
    for (final locale in ['ar', 'en', 'ur']) {
      for (final dark in [false, true]) {
        for (final scale in [1.0, 1.6]) {
          testWidgets('$page $locale dark=$dark scale=$scale', (tester) async {
            tester.view.physicalSize = Size(scale > 1 ? 320 : 390, 844);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            for (final entry in {
              'Cairo': 'assets/fonts/Cairo.ttf',
              'AmiriQuran': 'assets/fonts/AmiriQuran-Regular.ttf',
              'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
              'packages/cupertino_icons/CupertinoIcons':
                  'packages/cupertino_icons/assets/CupertinoIcons.ttf',
            }.entries) {
              final loader = FontLoader(entry.key)
                ..addFont(rootBundle.load(entry.value));
              await loader.load();
            }
            final tasbih = _Tasbih(), settings = _Settings();
            final boundary = GlobalKey();
            final prayer = PrayerTimesLoaded(
              prayerTimes: PrayerTimes(
                date: DateTime.now(),
                coordinates: Coordinates(21.4225, 39.8262),
                calculationParameters: CalculationMethodParameters.ummAlQura(),
              ),
              locationName: 'مكة المكرمة',
              currentTime: DateTime.now(),
            );
            final screen = switch (page) {
              'tasbih' => TasbihView(
                sessions: Stream.value(const <TasbihSession>[]),
              ),
              'dhikr' => const DhikrScreen(),
              'settings' => const SettingsScreenContent(),
              'prayers' => PrayerTimesContent(state: prayer),
              _ => const SizedBox.shrink(),
            };
            await tester.pumpWidget(
              MultiBlocProvider(
                providers: [
                  BlocProvider<TasbihBloc>.value(value: tasbih),
                  BlocProvider<SettingsScreenBloc>.value(value: settings),
                  BlocProvider(create: (_) => ThemeBloc()),
                  BlocProvider(create: (_) => LanguageBloc()),
                ],
                child: MaterialApp(
                  locale: Locale(locale),
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  theme: dark
                      ? AppTheme.getDarkTheme(Locale(locale))
                      : AppTheme.getLightTheme(Locale(locale)),
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.linear(scale)),
                    child: child!,
                  ),
                  home: Builder(
                    builder: (context) {
                      AppLocalizationsLookup.init(context);
                      return RepaintBoundary(key: boundary, child: screen);
                    },
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            if (locale == 'ar' &&
                scale == 1 &&
                const bool.fromEnvironment('CAPTURE_UI')) {
              await tester.runAsync(() async {
                final render =
                    boundary.currentContext!.findRenderObject()!
                        as RenderRepaintBoundary;
                final image = await render.toImage(pixelRatio: 2);
                final png = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                final file = File(
                  '${const String.fromEnvironment('UI_CAPTURE_DIR', defaultValue: 'report/ui/applied')}/$page-${dark ? 'dark' : 'light'}.png',
                );
                await file.parent.create(recursive: true);
                await file.writeAsBytes(png!.buffer.asUint8List());
                image.dispose();
              });
            }
            if (page == 'tasbih') {
              await tester.tap(find.text('12').first);
              await tester.pump();
              expect(tasbih.state.count, 13);
            }
            if (page == 'dhikr') {
              await tester.tap(find.byType(FilledButton).first);
              await tester.pumpAndSettle();
              final prefs = await SharedPreferences.getInstance();
              expect(
                prefs.getString('dhikr_library_counts'),
                contains('salawat'),
              );
            }
            final scroll = find.byType(Scrollable).last;
            if (scroll.evaluate().isNotEmpty) {
              await tester.drag(scroll, const Offset(0, -1400));
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
            await tester.pumpWidget(const SizedBox());
            await tasbih.close();
            await settings.close();
          });
        }
      }
    }
  }
}
