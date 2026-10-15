import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/persistence/auto_sync_service.dart';
import 'package:ramadan_assistant/core/persistence/prefs_sync_endpoint.dart';
import 'package:ramadan_assistant/core/persistence/sync_gateway.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/features/shortcuts/presentation/sync_settings_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auto_sync_service_test.dart' as fakes;

Widget _app(Widget child, String language) => MaterialApp(
  locale: Locale(language),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  theme: AppTheme.getLightTheme(Locale(language)),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  late PrefsSyncEndpointSource endpoint;
  late AutoSyncService sync;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    endpoint = PrefsSyncEndpointSource();
    sync = AutoSyncService(
      coordinator: SyncCoordinator(fakes.emptyStoreForTests(), fakes.OkGateway()),
      endpoint: endpoint,
      online: const Stream<bool>.empty(),
    );
  });

  for (final language in ['ar', 'en', 'ur']) {
    testWidgets('rejects http and saves https config ($language)', (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        _app(SyncSettingsCard(endpoint: endpoint, sync: sync), language),
      );
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'http://insecure.example');
      await tester.enterText(fields.at(1), 'tok');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(await endpoint.current(), isNull);

      await tester.enterText(fields.at(0), 'https://sync.example/');
      await tester.enterText(fields.at(1), 'tok');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      final saved = await endpoint.current();
      expect(saved?.baseUrl, 'https://sync.example');
      expect(saved?.token, 'tok');
      expect(tester.takeException(), isNull);
    });
  }
}
