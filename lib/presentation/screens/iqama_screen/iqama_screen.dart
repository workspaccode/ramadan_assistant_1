import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/iqama_screen/bloc/iqama_screen_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/iqama_screen/widgets/iqama_screen_content.dart';

class IqamaScreen extends StatelessWidget {
  final String prayerName;

  const IqamaScreen({super.key, required this.prayerName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IqamaScreenBloc(prayerName: prayerName),
      child: const IqamaScreenContent(),
    );
  }
}
