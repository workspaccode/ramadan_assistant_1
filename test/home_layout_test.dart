import 'dart:io';
import 'dart:ui' as ui;

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/normal_home_content.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/main_screen.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_state.dart';
import 'package:ramadan_assistant/presentation/screens/reminders_screen/bloc/reminders_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/bloc/tasbih_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _PrayerBloc extends Cubit<PrayerTimesState> implements PrayerTimesBloc {
  _PrayerBloc(super.state);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TasbihBloc extends Cubit<TasbihState> implements TasbihBloc {
  _TasbihBloc()
    : super(
        const TasbihCounting(
          count: 12,
          target: 33,
          currentDhikr: 'SubhanAllah',
        ),
      );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RemindersBloc extends Cubit<RemindersState> implements RemindersBloc {
  _RemindersBloc() : super(const RemindersLoaded([]));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'permission_rationale_shown': true,
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (call) async => 4,
        );
  });
  for (final locale in ['ar', 'en', 'ur']) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 1.6]) {
        testWidgets('Home $locale dark=$dark textScale=$scale has no overflow', (
          tester,
        ) async {
          tester.view.physicalSize = Size(scale > 1 ? 320 : 390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final font = FontLoader('Cairo')
            ..addFont(rootBundle.load('assets/fonts/Cairo.ttf'));
          await font.load();
          final icons = FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
          await icons.load();
          final prayer = _PrayerBloc(
            PrayerTimesLoaded(
              prayerTimes: PrayerTimes(
                date: DateTime.now(),
                coordinates: Coordinates(21.4225, 39.8262),
                calculationParameters: CalculationMethodParameters.ummAlQura(),
              ),
              locationName: locale == 'ar' ? 'مكة المكرمة' : 'Makkah',
              currentTime: DateTime.now(),
            ),
          );
          final tasbih = _TasbihBloc();
          final reminders = _RemindersBloc();
          final boundary = GlobalKey();
          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<PrayerTimesBloc>.value(value: prayer),
                BlocProvider<TasbihBloc>.value(value: tasbih),
                BlocProvider<RemindersBloc>.value(value: reminders),
              ],
              child: MaterialApp(
                locale: Locale(locale),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
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
                    return RepaintBoundary(
                      key: boundary,
                      child: const NormalHomeContent(),
                    );
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
                '${const String.fromEnvironment('UI_CAPTURE_DIR', defaultValue: 'report/ui/applied')}/home-${dark ? 'dark' : 'light'}-render.png',
              );
              await file.parent.create(recursive: true);
              await file.writeAsBytes(png!.buffer.asUint8List());
              image.dispose();
            });
          }
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -1500),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await prayer.close();
          await tasbih.close();
          await reminders.close();
        });
      }
    }
  }
  testWidgets('Root tabs show one navigation bar and retain dhikr counts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    AppTabNavigation.index.value = 0;
    final prayer = _PrayerBloc(PrayerTimesLoading());
    final tasbih = _TasbihBloc();
    final reminders = _RemindersBloc();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<PrayerTimesBloc>.value(value: prayer),
          BlocProvider<TasbihBloc>.value(value: tasbih),
          BlocProvider<RemindersBloc>.value(value: reminders),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.getLightTheme(const Locale('ar')),
          home: Builder(
            builder: (context) {
              AppLocalizationsLookup.init(context);
              return const MainScreen();
            },
          ),
        ),
      ),
    );
    // The loading bar is animated; advance explicitly instead of waiting for it to settle.
    await tester.pump(const Duration(milliseconds: 400));
    Future<void> select(String label) async {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }

    await select('الأذكار');
    expect(find.byType(NavigationBar), findsOneWidget);
    for (var attempt = 0; attempt < 4; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump(const Duration(milliseconds: 100));
    await select('الرئيسية');
    await select('الأذكار');
    expect(find.text('مرات 1'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await prayer.close();
    await tasbih.close();
    await reminders.close();
    AppTabNavigation.index.value = 0;
  });
}
