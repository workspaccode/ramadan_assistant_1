import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/persistence/auto_sync_service.dart';
import 'package:ramadan_assistant/core/persistence/document_store.dart';
import 'package:ramadan_assistant/core/persistence/prefs_sync_endpoint.dart';
import 'package:ramadan_assistant/core/platform/feature_platform.dart';
import 'package:ramadan_assistant/features/library/library_cubit.dart';
import 'package:ramadan_assistant/features/library/library_repository.dart';
import 'package:ramadan_assistant/features/library/library_screen.dart';
import 'package:ramadan_assistant/features/planner/data/document_planner_repository.dart';
import 'package:ramadan_assistant/features/planner/data/planner_platform_adapters.dart';
import 'package:ramadan_assistant/features/planner/presentation/planner_screen.dart';
import 'package:ramadan_assistant/features/shortcuts/presentation/shortcuts_screen.dart';
import 'package:ramadan_assistant/features/shortcuts/presentation/local_data_screen.dart';
import 'package:ramadan_assistant/features/worship/data/android_worship_adapters.dart';
import 'package:ramadan_assistant/features/worship/data/worship_repository.dart';
import 'package:ramadan_assistant/features/worship/presentation/worship_cubit.dart';
import 'package:ramadan_assistant/features/worship/presentation/worship_screen.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

/// The composition boundary keeps service lookup out of feature widgets.
class FeatureRoutes {
  static Widget planner() => PlannerScreen(
    repository: DocumentPlannerRepository(sl<DocumentStore>()),
    reminders: const AwesomePlannerReminders(),
    calendar: const AndroidDeviceCalendarPort(),
  );
  static Widget worship() => BlocProvider<WorshipCubit>(
    create: (_) => WorshipCubit(
      WorshipRepository(sl<DocumentStore>()),
      readers: const AndroidQuranReader(),
      overlays: AndroidReaderOverlay(),
      reminders: AwesomeWorshipReminder(),
    ),
    child: Builder(
      builder: (context) => WorshipScreen(cubit: context.read<WorshipCubit>()),
    ),
  );
  static Widget library() => BlocProvider<LibraryCubit>(
    create: (_) => LibraryCubit(LibraryRepository(sl<DocumentStore>()))..load(),
    child: const LibraryScreen(),
  );
  static Widget shortcuts() => ShortcutsScreen(platform: sl<FeaturePlatform>());
  static Widget localData() => LocalDataScreen(
    store: sl<DocumentStore>(),
    endpoint: sl<PrefsSyncEndpointSource>(),
    sync: sl<AutoSyncService>(),
  );

  static Future<void> openShortcut(
    BuildContext context,
    AppShortcut shortcut,
  ) async {
    if (!context.mounted) return;
    if (shortcut == AppShortcut.tasbih || shortcut == AppShortcut.prayers) {
      AppTabNavigation.select(context, shortcut == AppShortcut.tasbih ? 3 : 1);
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => switch (shortcut) {
          AppShortcut.worship => worship(),
          AppShortcut.planner => planner(),
          AppShortcut.library => library(),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
