import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/constants/umrah_duas.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_event.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_state.dart';
import 'package:ramadan_assistant/presentation/screens/umrah_guide_screen/widgets/umrah_guide_content.dart';
import 'package:ramadan_assistant/presentation/widgets/dua_widget.dart';

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
