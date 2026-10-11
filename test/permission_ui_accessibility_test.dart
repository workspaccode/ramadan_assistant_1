import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/core/theme/ramadan_theme_extension.dart';
import 'package:ramadan_assistant/core/utils/permission_flow.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen/bloc/settings_screen_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen/widgets/settings_screen_content.dart';

class _Settings extends Cubit<SettingsScreenState>
    implements SettingsScreenBloc {
  _Settings() : super(const SettingsScreenError('storage unavailable'));
  SettingsScreenEvent? last;
  @override
  void add(SettingsScreenEvent event) {
    last = event;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('ar'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: AppTheme.getLightTheme(const Locale('ar')),
  home: Builder(
    builder: (context) {
      AppLocalizationsLookup.init(context);
      return child;
    },
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
  var requested = 0;
  setUp(() {
    requested = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'checkPermissionStatus') return 0;
          if (call.method == 'requestPermissions') {
            requested++;
            return {
              for (final id in (call.arguments as List).cast<int>())
                id: id == Permission.location.value ? 1 : 4,
            };
          }
          return null;
        });
  });
  Future<BuildContext> contextFor(WidgetTester tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (value) {
            context = value;
            return const Scaffold();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return context;
  }

  testWidgets(
    'Automatic home entry does not re-prompt after rationale was seen',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'permission_rationale_shown': true,
      });
      final context = await contextFor(tester);
      expect(await PermissionFlow.requestCorePermissions(context), false);
      expect(requested, 0);
    },
  );
  testWidgets('Skip is remembered and never requests native permission', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final context = await contextFor(tester);
    final flow = PermissionFlow.requestCorePermissions(context);
    await tester.pumpAndSettle();
    await tester.tap(find.text('skip_for_now'.tr()));
    await tester.pumpAndSettle();
    expect(await flow, false);
    expect(requested, 0);
    expect(await PermissionFlow.requestCorePermissions(context), false);
    expect(requested, 0);
  });
  testWidgets('Explicit consent grants location and returns refresh signal', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final context = await contextFor(tester);
    final flow = PermissionFlow.requestCorePermissions(context);
    await tester.pumpAndSettle();
    await tester.tap(find.text('got_it_continue'.tr()));
    await tester.pumpAndSettle();
    expect(await flow, true);
    expect(requested, 2);
  });
  testWidgets('Settings failure offers retry instead of permanent loading', (
    tester,
  ) async {
    final bloc = _Settings();
    await tester.pumpWidget(
      _app(
        BlocProvider<SettingsScreenBloc>.value(
          value: bloc,
          child: const SettingsScreenContent(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('retry'.tr()));
    expect(bloc.last, isA<LoadSettings>());
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await bloc.close();
  });
  for (final palette in ['emerald', 'midnight', 'desert', 'ocean']) {
    for (final dark in [false, true]) {
      test(
        'Readable text and primary button contrast: $palette dark=$dark',
        () {
          final theme = dark
              ? AppTheme.getDarkTheme(const Locale('ar'), paletteId: palette)
              : AppTheme.getLightTheme(const Locale('ar'), paletteId: palette);
          final ext = theme.extension<RamadanThemeExtension>()!;
          double contrast(Color a, Color b) {
            final x = a.computeLuminance(), y = b.computeLuminance();
            return ((x > y ? x : y) + .05) / ((x < y ? x : y) + .05);
          }

          for (final foreground in [
            ext.textPrimary,
            ext.textSecondary,
            ext.textDim,
          ]) {
            for (final background in [
              ext.background,
              ext.cardSurface,
              ext.background2,
            ]) {
              expect(
                contrast(foreground, background),
                greaterThanOrEqualTo(4.5),
              );
            }
          }
          expect(
            contrast(theme.colorScheme.onPrimary, theme.colorScheme.primary),
            greaterThanOrEqualTo(4.5),
          );
        },
      );
    }
  }
}
