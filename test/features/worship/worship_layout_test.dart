import 'dart:io';
import 'dart:ui' as ui;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/persistence/drift_document_store.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/features/worship/data/worship_repository.dart';
import 'package:ramadan_assistant/features/worship/domain/worship_models.dart';
import 'package:ramadan_assistant/features/worship/presentation/worship_cubit.dart';
import 'package:ramadan_assistant/features/worship/presentation/worship_screen.dart';
import 'package:ramadan_assistant/features/worship/presentation/worship_strings.dart';

void main() {
  for (final locale in ['ar', 'en', 'ur']) {
    for (final dark in [false, true]) {
      testWidgets('Worship tabs and forms $locale dark=$dark at320 large text', (
        tester,
      ) async {
        final capture =
            locale == 'ar' && const bool.fromEnvironment('CAPTURE_WORSHIP');
        tester.view.physicalSize = Size(capture ? 390 : 320, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        final fonts = FontLoader('Cairo')
          ..addFont(rootBundle.load('assets/fonts/Cairo.ttf'));
        await fonts.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
        final boundary = GlobalKey();
        Future<void> captureTab(String name) async {
          if (!capture) return;
          await tester.runAsync(() async {
            final rendered =
                boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await rendered.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              'report/ui/features/worship-$name-${dark ? 'dark' : 'light'}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }

        final database = AppDatabase.forTesting(NativeDatabase.memory());
        final repository = WorshipRepository(DriftDocumentStore(database));
        final cubit = WorshipCubit(repository);
        await repository.savePlan(const WirdPlan(dailyPages: 3, nextPage: 603));
        await repository.initializeLedger({
          for (final prayer in ObligatoryPrayer.values) prayer: 2,
        });
        await repository.addVoluntary(VoluntaryWorship.nightPrayer, 4);
        addTearDown(cubit.close);
        addTearDown(database.close);
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: dark
                ? AppTheme.getDarkTheme(Locale(locale))
                : AppTheme.getLightTheme(Locale(locale)),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(capture ? 1 : 2)),
              child: child!,
            ),
            home: RepaintBoundary(
              key: boundary,
              child: WorshipScreen(cubit: cubit),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await captureTab('today');
        await tester.scrollUntilVisible(
          find.byType(ChoiceChip).first,
          120,
          scrollable: find
              .descendant(
                of: find.byType(ListView).first,
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        final chip = tester
            .widgetList<ChoiceChip>(find.byType(ChoiceChip))
            .firstWhere((chip) => chip.selected);
        final foreground = chip.labelStyle!.color!.computeLuminance();
        final background = chip.selectedColor!.computeLuminance();
        final contrast =
            ((foreground > background ? foreground : background) + .05) /
            ((foreground < background ? foreground : background) + .05);
        expect(contrast, greaterThanOrEqualTo(4.5));
        final copy = worshipCopy[locale]!;
        for (final key in ['worship_wird', 'worship_nawafil', 'worship_qada']) {
          final tab = find.widgetWithText(Tab, copy[key]!);
          await tester.ensureVisible(tab);
          await tester.pumpAndSettle();
          await tester.tap(tab);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await captureTab(key.replaceFirst('worship_', ''));
        }
        final pay = find
            .widgetWithText(FilledButton, copy['worship_pay']!)
            .first;
        await tester.ensureVisible(pay);
        await tester.pumpAndSettle();
        await tester.tap(pay);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(TextButton, copy['worship_cancel']!).last,
        );
        await tester.pumpAndSettle();
        final planTab = find.widgetWithText(Tab, copy['worship_wird']!);
        await tester.ensureVisible(planTab);
        await tester.pumpAndSettle();
        await tester.tap(planTab);
        await tester.pumpAndSettle();
        final edit = find.widgetWithText(
          TextButton,
          copy['worship_edit_plan']!,
        );
        await tester.ensureVisible(edit);
        await tester.pumpAndSettle();
        await tester.tap(edit);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
