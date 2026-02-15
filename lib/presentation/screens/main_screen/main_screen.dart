import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/bloc/main_screen_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/main_screen/widgets/main_screen_content.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainScreenBloc(),
      child: const MainScreenContent(),
    );
  }
}
