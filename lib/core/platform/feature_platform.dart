import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

enum AppShortcut { tasbih, prayers, worship, planner, library }

/// Retains notification destinations until the app's first usable frame.
class FeatureNavigation {
  static final pending = ValueNotifier<AppShortcut?>(null);
  static void request(AppShortcut destination) => pending.value = destination;
}

/// A small Android adapter. Unsupported platforms return capabilities honestly.
class FeaturePlatform {
  FeaturePlatform({MethodChannel? channel})
    : channel = channel ?? const MethodChannel('app.tawabti/features');
  final MethodChannel channel;
  final _shortcutEvents = StreamController<AppShortcut>.broadcast();
  Stream<AppShortcut> get shortcuts => _shortcutEvents.stream;

  AppShortcut? _parse(Object? value) {
    for (final shortcut in AppShortcut.values) {
      if (shortcut.name == value) return shortcut;
    }
    return null;
  }

  Future<AppShortcut?> initialize() async {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'shortcut.open') {
        final shortcut = _parse(call.arguments);
        if (shortcut != null && !_shortcutEvents.isClosed) {
          _shortcutEvents.add(shortcut);
        }
      }
    });
    try {
      return _parse(await channel.invokeMethod<String>('shortcuts.initial'));
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<bool> canPin() async {
    try {
      return await channel.invokeMethod<bool>('shortcuts.supported') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// True means a launcher confirmation was requested, not that it was accepted.
  Future<bool> requestPin(AppShortcut shortcut, String label) async =>
      await channel.invokeMethod<bool>('shortcuts.pin', {
        'id': shortcut.name,
        'label': label,
      }) ??
      false;

  Future<void> publishDynamic(Map<AppShortcut, String> shortcuts) async {
    try {
      await channel.invokeMethod<void>('shortcuts.dynamic', {
        'items': shortcuts.entries
            .map((entry) => {'id': entry.key.name, 'label': entry.value})
            .toList(),
      });
    } on MissingPluginException {
      /* The local app remains usable. */
    }
  }

  Future<void> dispose() async {
    channel.setMethodCallHandler(null);
    await _shortcutEvents.close();
  }
}
