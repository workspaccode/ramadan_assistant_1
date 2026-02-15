import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/qibla_screen/bloc/qibla_screen_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/qibla_screen/widgets/qibla_screen_content.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QiblaScreenBloc(),
      child: const QiblaScreenContent(),
    );
  }
}
