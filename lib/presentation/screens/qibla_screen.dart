import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/presentation/widgets/qibla_widgets.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('qibla_title'.tr()),
        centerTitle: true,
        elevation: 0,
      ),
      body: const QiblaCompass(),
    );
  }
}
