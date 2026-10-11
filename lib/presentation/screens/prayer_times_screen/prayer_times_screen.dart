import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_event.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/bloc/prayer_times_state.dart';
import 'package:ramadan_assistant/presentation/screens/prayer_times_screen/widgets/prayer_times_content.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SakinaBottomBar(selectedIndex: 1),
      body: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
        buildWhen: (previous, current) {
          if (previous is PrayerTimesLoaded && current is PrayerTimesLoaded) {
            // Only rebuild if prayer times or location changed
            return previous.prayerTimes != current.prayerTimes ||
                previous.locationName != current.locationName;
          }
          return true;
        },
        builder: (context, state) {
          if (state is PrayerTimesInitial || state is PrayerTimesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PrayerTimesLoaded) {
            return PrayerTimesContent(state: state);
          } else if (state is PrayerTimesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      color: context.primaryColor,
                      size: 40,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'error_prefix'.tr(args: [state.message]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.read<PrayerTimesBloc>().add(
                        LoadPrayerTimes(
                          locale: context.locale.languageCode,
                          requestPermission: true,
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text('retry'.tr()),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(child: Text('something_went_wrong'.tr()));
        },
      ),
    );
  }
}
