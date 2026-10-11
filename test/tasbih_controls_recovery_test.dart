import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/bloc/tasbih_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/widgets/tasbih_content.dart';

class _TasbihControls extends Cubit<TasbihState> implements TasbihBloc {
  _TasbihControls({bool failed = false})
    : super(
        failed
            ? const TasbihSaveFailed(
                count: 12,
                target: 33,
                currentDhikr: 'SubhanAllah',
                isCompleted: false,
              )
            : const TasbihCounting(
                count: 12,
                target: 33,
                currentDhikr: 'SubhanAllah',
              ),
      );

  final events = <TasbihEvent>[];

  @override
  void add(TasbihEvent event) {
    events.add(event);
    if (event is ChangeTarget) {
      emit(
        TasbihCounting(
          count: state.count,
          target: event.newTarget,
          currentDhikr: state.currentDhikr,
        ),
      );
    } else if (event is ChangeDhikr) {
      emit(
        TasbihCounting(
          count: 0,
          target: event.target,
          currentDhikr: event.newDhikr,
        ),
      );
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpTasbih(
  WidgetTester tester,
  _TasbihControls bloc, {
  Stream<List<TasbihSession>>? sessions,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
  addTearDown(bloc.close);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.getLightTheme(const Locale('en')),
      home: Builder(
        builder: (context) {
          AppLocalizationsLookup.init(context);
          // A route-local provider reproduces the scope of the app's lazy tabs.
          return BlocProvider<TasbihBloc>.value(
            value: bloc,
            child: TasbihView(sessions: sessions ?? Stream.value(const [])),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Target chips, picker keyboard and reset use the route-local bloc',
    (tester) async {
      final bloc = _TasbihControls();
      await _pumpTasbih(tester, bloc);
      for (final target in [100, 33]) {
        await tester.tap(find.widgetWithText(ChoiceChip, '$target').first);
        await tester.pumpAndSettle();
        expect(bloc.state.target, target);
      }
      final picker = find.widgetWithText(TextButton, 'dhikr_list'.tr());
      await tester.ensureVisible(picker);
      await tester.pumpAndSettle();
      await tester.tap(picker);
      await tester.pumpAndSettle();
      final sheet = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_DhikrSelectionSheet',
      );
      final sheetScroll = find
          .descendant(of: sheet, matching: find.byType(Scrollable))
          .first;
      for (final target in [99, 100, 1000, 33]) {
        final choice = find.descendant(
          of: sheet,
          matching: find.text('$target'),
        );
        await tester.scrollUntilVisible(choice, 200, scrollable: sheetScroll);
        await tester.ensureVisible(choice);
        await tester.pumpAndSettle();
        await tester.tap(choice);
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'start_tasbih'.tr()),
        );
        await tester.pumpAndSettle();
        expect(bloc.events.whereType<ChangeDhikr>().last.target, target);
        await tester.ensureVisible(picker);
        await tester.pumpAndSettle();
        await tester.tap(picker);
        await tester.pumpAndSettle();
      }
      final custom = find.text('custom_target'.tr());
      await tester.scrollUntilVisible(custom, 200, scrollable: sheetScroll);
      await tester.ensureVisible(custom);
      await tester.pumpAndSettle();
      await tester.tap(custom);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '0');
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'start_tasbih'.tr()),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(find.byType(TextField), '250');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      final start = find.widgetWithText(ElevatedButton, 'start_tasbih'.tr());
      expect(tester.getBottomLeft(start).dy, lessThanOrEqualTo(544));
      await tester.tap(start);
      await tester.pumpAndSettle();
      final changed = bloc.events.whereType<ChangeDhikr>().last;
      expect(changed.newDhikr, 'SubhanAllah');
      expect(changed.target, 250);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.restart_alt_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'reset'.tr()));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<ResetCounter>(), hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Save failure retains the count and exposes an accessible retry',
    (tester) async {
      final bloc = _TasbihControls(failed: true);
      await _pumpTasbih(tester, bloc);
      expect(find.text('12'), findsOneWidget);
      expect(
        find.text(AppLocalizationsLookup.instance.ui_tasbih_save_failed),
        findsOneWidget,
      );
      final retry = find.widgetWithText(TextButton, 'retry'.tr());
      await tester.ensureVisible(retry);
      await tester.pumpAndSettle();
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<RetryTasbihSave>(), hasLength(1));
      expect(bloc.state.count, 12);
      expect(tester.takeException(), isNull);
    },
  );
}
