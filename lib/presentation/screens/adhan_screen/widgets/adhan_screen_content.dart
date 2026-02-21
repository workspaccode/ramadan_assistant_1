import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/adhan_screen/bloc/adhan_screen_bloc.dart';

class AdhanScreenContent extends StatefulWidget {
  const AdhanScreenContent({super.key});

  @override
  State<AdhanScreenContent> createState() => _AdhanScreenContentState();
}

class _AdhanScreenContentState extends State<AdhanScreenContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _animationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String _formatCountdown(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdhanScreenBloc, AdhanScreenState>(
      builder: (context, state) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D4F30),
                  Color(0xFF06402B),
                  Color(0xFF032819),
                ],
              ),
            ),
            child: SafeArea(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: _buildContent(context, state),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AdhanScreenState state) {
    if (state is AdhanScreenDhikr) {
      return _buildDhikrView(context, state);
    }

    final prayerName = state is AdhanScreenPlaying
        ? state.prayerName
        : (state is AdhanScreenCompleted ? state.prayerName : '');

    return Column(
      children: [
        // Close button
        Align(
          alignment:
              context.locale.languageCode == 'ar' ||
                  context.locale.languageCode == 'ur'
              ? Alignment.topLeft
              : Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        const Spacer(),

        // Islamic decorative pattern
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.secondaryColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: context.secondaryColor.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Icon(Icons.mosque, color: context.secondaryColor, size: 80),
        ),

        const SizedBox(height: 40),

        // "حان وقت الصلاة" (Prayer Time)
        Text(
          'adhan_call_to_prayer'.tr(),
          style: TextStyle(
            color: context.secondaryColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Amiri',
          ),
        ),

        const SizedBox(height: 20),

        // Prayer Name
        Text(
          prayerName.toLowerCase().tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 40),

        // Iqama Countdown or Reminder
        if (state is AdhanScreenPlaying)
          state.showIqamaReminder
              ? _buildIqamaReminder(context)
              : _buildIqamaCountdown(context, state.iqamaCountdown),

        if (state is AdhanScreenCompleted)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'تقبل الله منا ومنكم صالح الأعمال'.tr(),
              style: TextStyle(
                color: context.secondaryColor,
                fontSize: 20,
                fontFamily: 'Amiri',
              ),
            ),
          ),

        const Spacer(),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              if (state is AdhanScreenPlaying)
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AdhanScreenBloc>().add(StopAdhan());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.secondaryColor,
                    foregroundColor: context.primaryColor,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.volume_off),
                  label: Text(
                    'stop_adhan'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (state is AdhanScreenPlaying && state.showIqamaReminder) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AdhanScreenBloc>().add(StartDhikr());
                    HapticFeedback.mediumImpact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    side: BorderSide(color: context.secondaryColor, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    'start_dhikr'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (state is AdhanScreenCompleted)
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AdhanScreenBloc>().add(StartDhikr());
                    HapticFeedback.mediumImpact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.secondaryColor,
                    foregroundColor: context.primaryColor,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    'بدء أذكار الصلاة'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDhikrView(BuildContext context, AdhanScreenDhikr state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  context.read<AdhanScreenBloc>().add(StopAdhan());
                  Navigator.pop(context);
                },
              ),
              Text(
                'أذكار الصلاة'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48), // Spacer
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            context.read<AdhanScreenBloc>().add(IncrementDhikr());
            HapticFeedback.lightImpact();
          },
          child: Column(
            children: [
              Text(
                state.dhikrText,
                style: TextStyle(
                  color: context.secondaryColor,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: state.count / state.target,
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.secondaryColor,
                      ),
                    ),
                  ),
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: context.secondaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${state.count}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '${'target'.tr()}: ${state.target}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'اضغط في أي مكان للتسبيح'.tr(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIqamaCountdown(BuildContext context, int countdown) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'iqama_in'.tr(),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            _formatCountdown(countdown),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIqamaReminder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: context.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.secondaryColor.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.access_alarm, color: context.primaryColor, size: 40),
          const SizedBox(height: 10),
          Text(
            'time_for_iqama'.tr(),
            style: TextStyle(
              color: context.primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
            ),
          ),
          if (context.locale.languageCode != 'ar')
            Text(
              'حان وقت الإقامة',
              style: TextStyle(
                color: context.primaryColor,
                fontSize: 18,
                fontFamily: 'Amiri',
              ),
            ),
        ],
      ),
    );
  }
}
