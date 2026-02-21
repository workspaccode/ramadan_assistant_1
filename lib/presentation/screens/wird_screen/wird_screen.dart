import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_event.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_state.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/widgets/wird_history_view.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/widgets/wird_selection_view.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/widgets/wird_tracker_view.dart';

class WirdScreen extends StatelessWidget {
  const WirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WirdBloc(sl())..add(LoadWirdProgress()),
      child: const WirdView(),
    );
  }
}

class WirdView extends StatelessWidget {
  const WirdView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;

    return BlocBuilder<WirdBloc, WirdState>(
      builder: (context, state) {
        if (state is WirdLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is WirdNoPlan) {
          return Scaffold(
            backgroundColor: theme.background,
            appBar: AppBar(
              title: Text(
                'wird_title'.tr(),
                style: TextStyle(color: theme.textPrimary),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: theme.textPrimary),
            ),
            body: const WirdSelectionView(),
          );
        }

        // Active Plan or History: Show Tabs
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: theme.background,
            appBar: AppBar(
              title: Text(
                'wird_title'.tr(),
                style: TextStyle(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: theme.textPrimary),
              bottom: TabBar(
                indicatorColor: theme.primary,
                labelColor: theme.primary,
                unselectedLabelColor: theme.textSecondary,
                tabs: [
                  Tab(text: 'wird_tracker'.tr()),
                  Tab(text: 'wird_history'.tr()),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                state is WirdPlanActive
                    ? WirdTrackerView(state: state)
                    : const Center(
                        child: CircularProgressIndicator(),
                      ), // Should be active if not loading/noplan
                const WirdHistoryView(),
              ],
            ),
          ),
        );
      },
    );
  }
}
