import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/iqama_screen/bloc/iqama_screen_bloc.dart';

class IqamaScreenContent extends StatefulWidget {
  const IqamaScreenContent({super.key});

  @override
  State<IqamaScreenContent> createState() => _IqamaScreenContentState();
}

class _IqamaScreenContentState extends State<IqamaScreenContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IqamaScreenBloc, IqamaScreenState>(
      listener: (context, state) {
        if (state is IqamaScreenDismissed) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<IqamaScreenBloc, IqamaScreenState>(
        builder: (context, state) {
          if (state is! IqamaScreenReminder) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.secondaryColor,
                    context.secondaryColor.withValues(alpha: 0.8),
                    context.primaryColor,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulsing alarm icon
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.access_alarm,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Iqama text
                    Text(
                      'time_for_iqama'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${'iqama_time'.tr()} - ${state.prayerName.toLowerCase().tr()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Arabic prayer phrase
                    Text(
                      'prayer_about_to_begin'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontFamily: 'Amiri',
                      ),
                    ),

                    if (context.locale.languageCode != 'ar')
                      const Text(
                        'قَدْ قَامَتِ الصَّلَاةُ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Amiri',
                        ),
                      ),

                    const SizedBox(height: 60),

                    // Dismiss button
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<IqamaScreenBloc>().add(DismissIqama());
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: context.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.check),
                      label: Text(
                        'got_it'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
