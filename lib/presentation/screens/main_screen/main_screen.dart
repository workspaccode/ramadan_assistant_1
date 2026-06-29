import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/bloc/main_screen_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/widgets/main_screen_content.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/normal_home_content.dart';

bool get isCurrentlyRamadan {
  final today = HijriCalendar.now();
  return today.hMonth == 9;
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainScreenBloc(),
      child: isCurrentlyRamadan
          ? const MainScreenContent()
          : const NormalHomeContent(),
    );
  }
}
