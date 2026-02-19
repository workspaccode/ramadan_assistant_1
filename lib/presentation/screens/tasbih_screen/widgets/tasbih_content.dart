import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/bloc/tasbih_bloc.dart';
import 'package:vibration/vibration.dart';

class TasbihView extends StatelessWidget {
  const TasbihView({super.key});

  @override
  Widget build(BuildContext context) {
    final today = HijriCalendar.now();
    final isRamadan = today.hMonth == 9;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Stack(
        children: [
          // Ramadan Background Images
          if (isRamadan) ...[
           
            Positioned(
              top: 200,
              left: 30,
              child: Opacity(
                opacity: 0.2,
                child: SvgPicture.asset(
                  'assets/ra3.svg',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ],
          // Main Content
          SafeArea(
            child: Column(
              children: [
                //  _buildRamadanHeader(context, isRamadan),
                Expanded(
                  child: BlocBuilder<TasbihBloc, TasbihState>(
                    builder: (context, state) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildDhikrCard(context, state),
                            const SizedBox(height: 20),
                            _buildTasbihCounter(context, state),
                            const SizedBox(height: 20),
                            _buildProgressIndicator(context, state),
                            const SizedBox(height: 20),
                            _buildActionButtons(context),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRamadanHeader(BuildContext context, bool isRamadan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isRamadan ? const Color(0xFF2E7D32) : const Color(0xFF1976D2),
            isRamadan ? const Color(0xFF4CAF50) : const Color(0xFF42A5F5),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/image/ramadan_moon.svg',
                width: 32,
                height: 32,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                'tasbih_title'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              SvgPicture.asset(
                'assets/image/ramadan_moon.svg',
                width: 32,
                height: 32,
                color: Colors.white,
              ),
            ],
          ),
          if (isRamadan) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'وَذَكِرُوا اللَّهَ كَثِيرًا لَعَلَّكُمْ تُفْلِحُونَ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDhikrCard(BuildContext context, TasbihState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2E7D32), const Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            state.currentDhikr.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '${'target'.tr()}: ${state.target}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasbihCounter(BuildContext context, TasbihState state) {
    final progress = state.count / state.target;
    final isCompleted = state.count >= state.target;

    return GestureDetector(
      onTap: () async {
        await Vibration.vibrate(duration: 50);
        context.read<TasbihBloc>().add(IncrementCounter());

        if (isCompleted) {
          await Vibration.vibrate(duration: 200);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCompleted
                ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                : [const Color(0xFF2E7D32), const Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  (isCompleted
                          ? const Color(0xFFFFD700)
                          : const Color(0xFF2E7D32))
                      .withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${state.count}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${'target'.tr()}: ${state.target}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.star, color: Colors.white, size: 24),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, TasbihState state) {
    final progress = state.count / state.target;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقدم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.primaryColor,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0
                  ? const Color(0xFFFFD700)
                  : const Color(0xFF2E7D32),
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildModernActionButton(
          context,
          icon: Icons.refresh_rounded,
          label: 'reset'.tr(),
          color: Colors.orange,
          onPressed: () => context.read<TasbihBloc>().add(ResetCounter()),
        ),
        _buildModernActionButton(
          context,
          icon: Icons.list_rounded,
          label: 'dhikr_list'.tr(),
          color: const Color(0xFF2E7D32),
          onPressed: () => _showDhikrPicker(context),
        ),
      ],
    );
  }

  Widget _buildModernActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.onBackgroundColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: context.secondaryColor,
            foregroundColor: context.onSecondaryColor,
            minimumSize: const Size(64, 64),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.onBackgroundColor,
          ),
        ),
      ],
    );
  }

  void _showDhikrPicker(BuildContext context) {
    final ramadanDhikrs = [
      {'id': 'SubhanAllah', 'target': 33, 'reward': 'حسنات بعدد كل ذرة'},
      {'id': 'Alhamdulillah', 'target': 33, 'reward': 'حسنات بعدد كل ذرة'},
      {'id': 'Allahu Akbar', 'target': 33, 'reward': 'حسنات بعدد كل ذرة'},
      {'id': 'La ilaha illallah', 'target': 100, 'reward': 'أفضل الذكر'},
      {'id': 'Astaghfirullah', 'target': 100, 'reward': 'مغفرة للذنوب'},
      {
        'id': 'salawat',
        'target': 100,
        'reward': 'الصلاة على النبي صلى الله عليه وسلم',
      },
      {
        'id': 'subhanallah_wabihamdihi',
        'target': 100,
        'reward': 'تملأ ميزان الحسنات',
      },
      {'id': 'lahawla', 'target': 100, 'reward': 'كنز من كنوز الجنة'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/image/ramadan_star.svg',
                      width: 24,
                      height: 24,
                      color: const Color(0xFF2E7D32),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'select_dhikr'.tr(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: ramadanDhikrs.length,
                  itemBuilder: (context, index) {
                    final d = ramadanDhikrs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2E7D32).withOpacity(0.1),
                            const Color(0xFF4CAF50).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2E7D32).withOpacity(0.2),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        title: Text(
                          (d['id'] as String).tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${'target'.tr()}: ${d['target']}',
                              style: TextStyle(
                                color: context.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (d['reward'] != null)
                              Text(
                                d['reward'] as String,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onTap: () {
                          context.read<TasbihBloc>().add(
                            ChangeDhikr(d['id'] as String, d['target'] as int),
                          );
                          Navigator.pop(bottomSheetContext);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
