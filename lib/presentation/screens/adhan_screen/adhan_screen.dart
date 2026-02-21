import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/screens/adhan_screen/bloc/adhan_screen_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/adhan_screen/widgets/adhan_screen_content.dart';

class AdhanScreen extends StatelessWidget {
  final String prayerName;
  final int iqamaDelayMinutes;

  const AdhanScreen({
    super.key,
    required this.prayerName,
    this.iqamaDelayMinutes = 10,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdhanScreenBloc(
        database: context.read<AppDatabase>(),
        prayerName: prayerName,
        iqamaDelayMinutes: iqamaDelayMinutes,
      ),
      child: const AdhanScreenContent(),
    );
  }
}
