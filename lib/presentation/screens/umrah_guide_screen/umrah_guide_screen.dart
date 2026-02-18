import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_event.dart';
import 'package:ramadan_assistant/presentation/screens/umrah_guide_screen/widgets/umrah_guide_content.dart';

class UmrahGuideScreen extends StatelessWidget {
  const UmrahGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UmrahGuideBloc(context.read<AppDatabase>())..add(LoadUmrahProgress()),
      child: const UmrahGuideView(),
    );
  }
}
