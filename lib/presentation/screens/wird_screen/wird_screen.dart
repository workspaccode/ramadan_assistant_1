import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_event.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_state.dart';
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

    return Scaffold(
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
      ),
      body: BlocBuilder<WirdBloc, WirdState>(
        builder: (context, state) {
          if (state is WirdLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WirdNoPlan) {
            return const WirdSelectionView();
          }

          if (state is WirdPlanActive) {
            return WirdTrackerView(state: state);
          }

          if (state is WirdError) {
            return Center(
              child: Text(state.message, style: TextStyle(color: theme.error)),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
