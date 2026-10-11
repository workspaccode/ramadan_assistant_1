import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/main.dart';

void main() {
  testWidgets('Startup renders immediately while initialization is pending', (
    tester,
  ) async {
    final pending = Completer<void>();
    await tester.pumpWidget(
      AppStartup(
        initialize: () => pending.future,
        child: const MaterialApp(home: Text('Ready')),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Ready'), findsNothing);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('Startup failure presents retry and retry opens the app', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      AppStartup(
        initialize: () async {
          if (++attempts == 1) throw StateError('Plugin initialization failed');
        },
        child: const MaterialApp(home: Text('Ready')),
      ),
    );
    expect(tester.takeException(), isA<StateError>());
    await tester.pumpAndSettle();
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text('Ready'), findsOneWidget);
  });
}
