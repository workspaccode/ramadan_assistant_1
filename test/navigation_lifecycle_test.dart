import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/widgets/prayer_times_content.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('en'),
  theme: AppTheme.getLightTheme(const Locale('en')),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Builder(
    builder: (context) {
      AppLocalizationsLookup.init(context);
      return child;
    },
  ),
);

void main() {
  final times = PrayerTimes(
    date: DateTime(2026, 10, 10),
    coordinates: const Coordinates(21.4225, 39.8262),
    calculationParameters: CalculationMethodParameters.ummAlQura(),
  );

  test('Next prayer excludes sunrise and uses calculated next-day Fajr', () {
    expect(
      nextObligatoryPrayer(
        times,
        times.fajr.add(const Duration(minutes: 1)),
      ).name,
      'dhuhr',
    );
    expect(
      nextObligatoryPrayer(
        times,
        times.isha.add(const Duration(minutes: 1)),
      ).time,
      times.fajrAfter.toLocal(),
    );
    expect(nextObligatoryPrayer(times, times.isha).name, 'fajr');
  });

  testWidgets('Retained root pages observe active tab changes', (tester) async {
    final selected = ValueNotifier(1);
    addTearDown(selected.dispose);
    await tester.pumpWidget(
      _app(
        ValueListenableBuilder<int>(
          valueListenable: selected,
          builder: (context, index, _) => AppShellScope(
            activeTab: index,
            child: Builder(
              builder: (context) => Text(
                AppShellScope.isActive(context, 1) ? 'active' : 'hidden',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('active'), findsOneWidget);
    selected.value = 0;
    await tester.pump();
    expect(find.text('hidden'), findsOneWidget);
  });
}
