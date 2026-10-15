import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/platform/feature_platform.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

class ShortcutsScreen extends StatefulWidget {
  const ShortcutsScreen({super.key, required this.platform});
  final FeaturePlatform platform;
  @override
  State<ShortcutsScreen> createState() => _ShortcutsScreenState();
}

class _ShortcutsScreenState extends State<ShortcutsScreen> {
  late Future<bool> _supported = widget.platform.canPin();
  bool _busy = false;

  Future<void> _pin(AppShortcut shortcut, String label) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final requested = await widget.platform.requestPin(shortcut, label);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              requested
                  ? context.loc.features_pin_requested
                  : context.loc.features_shortcuts_unsupported,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.loc.features_action_failed)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = <AppShortcut, String>{
      AppShortcut.tasbih: context.loc.tasbih,
      AppShortcut.prayers: context.loc.prayer_times,
      AppShortcut.worship: context.loc.features_worship,
      AppShortcut.planner: context.loc.features_planner,
      AppShortcut.library: context.loc.features_library,
    };
    const icons = [
      Icons.touch_app_outlined,
      Icons.access_time_rounded,
      Icons.bookmark_outline_rounded,
      Icons.calendar_month_outlined,
      Icons.library_books_outlined,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(context.loc.features_shortcuts)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              context.loc.features_shortcuts_intro,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FutureBuilder<bool>(
              future: _supported,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data != true) {
                  return SakinaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.loc.features_shortcuts_unsupported),
                        TextButton(
                          onPressed: () => setState(
                            () => _supported = widget.platform.canPin(),
                          ),
                          child: Text(context.loc.retry),
                        ),
                      ],
                    ),
                  );
                }
                return SakinaCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final shortcut in AppShortcut.values)
                        ListTile(
                          minTileHeight: 64,
                          leading: Icon(
                            icons[shortcut.index],
                            color: context.primaryColor,
                          ),
                          title: Text(labels[shortcut]!),
                          trailing: const Icon(
                            Icons.add_to_home_screen_outlined,
                          ),
                          onTap: _busy
                              ? null
                              : () => _pin(shortcut, labels[shortcut]!),
                        ),
                    ],
                  ),
                );
              },
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
