import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ramadan_assistant/core/constants/umrah_duas.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_event.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_state.dart';
import 'package:ramadan_assistant/presentation/widgets/dua_widget.dart';

class UmrahGuideView extends StatefulWidget {
  const UmrahGuideView({super.key});

  @override
  State<UmrahGuideView> createState() => _UmrahGuideViewState();
}

class _UmrahGuideViewState extends State<UmrahGuideView>
    with TickerProviderStateMixin {
  int _tawafCircuits = 0;
  int _saiLaps = 0;
  bool _isPrayedAtMaqam = false;
  bool _isDrunkZamzam = false;
  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: BlocBuilder<UmrahGuideBloc, UmrahGuideState>(
        builder: (context, state) {
          if (state is UmrahGuideInitial || state is UmrahGuideLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UmrahGuideLoaded) {
            return _buildBody(context, state.progress);
          } else if (state is UmrahGuideError) {
            return Center(
              child: Text('error_prefix'.tr(args: [state.message])),
            );
          }
          return Center(child: Text('something_went_wrong'.tr()));
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<UmrahProgressData> steps) {
    final completedCount = steps.where((s) => s.completed).length;
    final progress = completedCount / steps.length;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // iOS-style Large Title AppBar
        SliverAppBar(
          expandedHeight: 160,
          floating: false,
          pinned: true,
          stretch: true,
          backgroundColor: context.isDark
              ? const Color(0xFF1A1A2E)
              : context.primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(
              bottom: 16,
              left: 20,
              right: 20,
            ),
            title: Text(
              'umrah_title'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: context.isDark
                      ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                      : [
                          context.primaryColor,
                          context.primaryColor.withValues(alpha: 0.8),
                        ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 50),
                  child: Row(
                    children: [
                      // Progress Ring
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 56,
                              height: 56,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 4,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Text(
                              '$completedCount/${steps.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              completedCount == steps.length
                                  ? 'تقبل الله عمرتك 🤲'
                                  : 'تقدّم العمرة',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.2,
                                ),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  context.secondaryColor,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'refresh_tooltip'.tr(),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () {
                setState(() {
                  _tawafCircuits = 0;
                  _saiLaps = 0;
                  _isPrayedAtMaqam = false;
                  _isDrunkZamzam = false;
                  _expandedIndex = -1;
                });
                context.read<UmrahGuideBloc>().add(ResetUmrahProgress());
              },
            ),
          ],
        ),

        // Steps Timeline
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final step = steps[index];
              final isNext =
                  !step.completed && (index == 0 || steps[index - 1].completed);
              final isExpanded = _expandedIndex == index;
              final isLast = index == steps.length - 1;

              return _buildStepCard(
                context,
                step: step,
                index: index,
                isNext: isNext,
                isExpanded: isExpanded,
                isLast: isLast,
                totalSteps: steps.length,
              );
            }, childCount: steps.length),
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required UmrahProgressData step,
    required int index,
    required bool isNext,
    required bool isExpanded,
    required bool isLast,
    required int totalSteps,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  // Step circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    width: isNext ? 44 : 38,
                    height: isNext ? 44 : 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: step.completed
                          ? const LinearGradient(
                              colors: [Color(0xFF34C759), Color(0xFF30D158)],
                            )
                          : isNext
                          ? LinearGradient(
                              colors: [
                                context.secondaryColor,
                                context.secondaryColor.withValues(alpha: 0.8),
                              ],
                            )
                          : null,
                      color: step.completed || isNext
                          ? null
                          : context.isDark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      boxShadow: isNext
                          ? [
                              BoxShadow(
                                color: context.secondaryColor.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: step.completed
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            )
                          : (index + 1 >= 3 && index + 1 <= 5)
                          ? SvgPicture.asset(
                              'assets/${index + 1}.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                isNext ? Colors.white : Colors.grey,
                                BlendMode.srcIn,
                              ),
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isNext
                                    ? Colors.white
                                    : context.textTheme.bodyMedium?.color
                                          ?.withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                  // Connecting line
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2.5,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          // gradient: LinearGradient(
                          //   begin: Alignment.topCenter,
                          //   end: Alignment.bottomCenter,
                          //   colors: step.completed
                          //       ? [
                          //           const Color(0xFF34C759),
                          //           const Color(
                          //             0xFF34C759,
                          //           ).withValues(alpha: 0.3),
                          //         ]
                          //       : [
                          //           Colors.grey.withValues(alpha: 0.3),
                          //           Colors.grey.withValues(alpha: 0.1),
                          //         ],
                          // ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _expandedIndex = isExpanded ? -1 : index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? Colors.white.withValues(alpha: isNext ? 0.08 : 0.04)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      // border: Border.all(
                      //   color: isNext
                      //       ? context.secondaryColor.withValues(alpha: 0.5)
                      //       : step.completed
                      //       ? const Color(0xFF34C759).withValues(alpha: 0.3)
                      //       : Colors.grey.withValues(alpha: 0.15),
                      //   width: isNext ? 1.5 : 1,
                      // ),
                      boxShadow: [
                        BoxShadow(
                          color: isNext
                              ? context.secondaryColor.withValues(alpha: 0.1)
                              : Colors.black.withValues(
                                  alpha: context.isDark ? 0.2 : 0.04,
                                ),
                          blurRadius: isNext ? 16 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step.step.tr(),
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: step.completed
                                            ? Colors.grey
                                            : context.onSurfaceColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _buildStatusChip(context, step, isNext),
                                  ],
                                ),
                              ),
                              AnimatedRotation(
                                duration: const Duration(milliseconds: 300),
                                turns: isExpanded ? 0.5 : 0,
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: isNext
                                      ? context.secondaryColor
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Expandable Content
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: _buildExpandedContent(
                            context,
                            step,
                            index,
                            isNext,
                            totalSteps,
                          ),
                          crossFadeState: isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 350),
                          sizeCurve: Curves.easeOutCubic,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    UmrahProgressData step,
    bool isNext,
  ) {
    Color chipColor;
    String label;
    IconData icon;

    if (step.completed) {
      chipColor = context.onBackgroundColor;
      label = 'completed'.tr();
      icon = Icons.check_circle_rounded;
    } else if (isNext) {
      chipColor = context.secondaryColor;
      label = 'current_stage'.tr();
      icon = Icons.play_circle_rounded;
    } else {
      chipColor = context.isDark ? Colors.grey[400]! : Colors.grey[600]!;
      label = 'waiting'.tr();
      icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    UmrahProgressData step,
    int index,
    bool isNext,
    int totalSteps,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 16),

          // Guidelines section
          Text(
            'guidelines_title'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: context.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildGuidelineWidgets(context, step.step, step.completed),

          const SizedBox(height: 16),

          // Special buttons per step
          if (step.step == 'الإحرام') ...[
            _buildActionButton(
              context,
              icon: Icons.info_outline_rounded,
              label: 'ishtirat_dua'.tr(),
              color: context.primaryColor,
              onPressed: () => _showIshtiratBottomSheet(context),
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              context,
              icon: Icons.menu_book_rounded,
              label: 'أدعية الطواف والسعي الثابتة',
              color: context.secondaryColor,
              onPressed: () => _showDuasBottomSheet(context, step.step),
            ),
          ],

          if (step.step == 'الطواف' || step.step == 'السعي') ...[
            _buildActionButton(
              context,
              icon: Icons.menu_book_rounded,
              label: step.step == 'السعي'
                  ? 'أدعية السعي الشاملة'
                  : 'أدعية الطواف الشاملة',
              color: context.secondaryColor,
              onPressed: () => _showDuasBottomSheet(context, step.step),
            ),
          ],

          const SizedBox(height: 16),

          // Duas inline
          if (step.step == 'السعي') ...[
            _buildSectionTitle('dhikr_standing'.tr()),
            const SizedBox(height: 10),
            DuaWidget(
              arabicText:
                  'اللهُ أَكْبَر، اللهُ أَكْبَر، اللهُ أَكْبَر. لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ. لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ، أَنْجَزَ وَعْدَهُ، وَنَصَرَ عَبْدَهُ، وَهَزَمَ الْأَعْزَابَ وَحْدَهُ.',
              translation: 'dhikr_safa_marwa_standing_trans'.tr(),
            ),
            const SizedBox(height: 12),
            _buildSectionTitle('dhikr_walking'.tr()),
            const SizedBox(height: 10),
            DuaWidget(
              arabicText:
                  'رَبَّنَا آتِنَا فِي الدِّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ.',
              translation: 'dua_rabbana_atina_trans'.tr(),
            ),
            const SizedBox(height: 12),
            DuaWidget(
              arabicText:
                  'رَبِّ اغْفِرْ وَارْحَمْ، وَتَجَاوَزْ عَمَّا تَعْلَمُ، إِنَّكَ أَنْتَ الْأَعَزُّ الْأَكْرَمُ.',
              translation: 'dua_rabbi_ighfir_trans'.tr(),
            ),
            const SizedBox(height: 12),
            DuaWidget(
              arabicText:
                  'اللهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى.',
              translation: 'dua_allahumma_inni_asaluka_trans'.tr(),
            ),
          ] else if (_getDuaArabic(step.step).isNotEmpty) ...[
            _buildSectionTitle('adhkar_title'.tr()),
            const SizedBox(height: 10),
            DuaWidget(
              arabicText: _getDuaArabic(step.step),
              translation: _getDuaTranslation(step.step),
            ),
          ],

          const SizedBox(height: 20),

          // Completion button
          if (!step.completed && isNext)
            _buildCompletionButton(context, step, index, totalSteps),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: context.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: context.primaryColor,
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: context.textTheme.labelLarge),
        style: TextButton.styleFrom(
          foregroundColor: color,
          backgroundColor: color.withValues(alpha: 0.08),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionButton(
    BuildContext context,
    UmrahProgressData step,
    int index,
    int totalSteps,
  ) {
    final canComplete = _canCompleteStep(step.step);

    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: canComplete
              ? () {
                  context.read<UmrahGuideBloc>().add(
                    CompleteUmrahStep(step.id),
                  );
                  if (index == totalSteps - 1) {
                    _showCompletionBottomSheet(context);
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canComplete
                ? context.primaryColor
                : Colors.grey.withValues(alpha: 0.3),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.withValues(alpha: 0.15),
            disabledForegroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: canComplete ? 2 : 0,
            shadowColor: context.primaryColor.withValues(alpha: 0.3),
          ),
          child: Text(
            step.step == 'الطواف' && !canComplete
                ? 'complete_tawaf_first'.tr()
                : 'complete_button'.tr(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // ─── Guideline Widgets ──────────────────────

  List<Widget> _buildGuidelineWidgets(
    BuildContext context,
    String step,
    bool completed,
  ) {
    final points = _getGuidelinePoints(step);

    return List.generate(points.length, (index) {
      final point = points[index];

      if (step == 'الطواف' && index == 0 && !completed) {
        return _buildCircularCounter(
          context,
          label: point,
          current: _tawafCircuits,
          max: 7,
          onChanged: (val) => setState(() => _tawafCircuits = val),
          successText: 'tawaf_done'.tr(),
        );
      }

      if (step == 'الطواف' && index == 3 && !completed) {
        return _buildIOSToggle(point, _isPrayedAtMaqam, (val) {
          setState(() => _isPrayedAtMaqam = val);
        });
      }
      if (step == 'الطواف' && index == 4 && !completed) {
        return _buildIOSToggle(point, _isDrunkZamzam, (val) {
          setState(() => _isDrunkZamzam = val);
        });
      }

      if (step == 'السعي' && index == 0 && !completed) {
        return _buildCircularCounter(
          context,
          label: point,
          current: _saiLaps,
          max: 7,
          onChanged: (val) => setState(() => _saiLaps = val),
          successText: 'sai_done'.tr(),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.primaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(point, style: context.textTheme.bodyMedium)),
          ],
        ),
      );
    });
  }

  // ─── Circular Counter (iOS Activity Ring style) ──────

  Widget _buildCircularCounter(
    BuildContext context, {
    required String label,
    required int current,
    required int max,
    required Function(int) onChanged,
    required String successText,
  }) {
    final progress = current / max;
    final isDone = current == max;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : context.secondaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? const Color(0xFF34C759).withValues(alpha: 0.4)
              : context.secondaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Ring progress
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _RingPainter(
                      progress: progress,
                      ringColor: isDone
                          ? const Color(0xFF34C759)
                          : context.secondaryColor,
                      trackColor: context.isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFE5E5EA),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$current',
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: isDone
                            ? const Color(0xFF34C759)
                            : context.secondaryColor,
                      ),
                    ),
                    Text('/ $max', style: context.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // +/- buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircularButton(
                icon: Icons.remove_rounded,
                onPressed: current > 0 ? () => onChanged(current - 1) : null,
                color: context.primaryColor,
              ),
              const SizedBox(width: 32),
              _buildCircularButton(
                icon: Icons.add_rounded,
                onPressed: current < max ? () => onChanged(current + 1) : null,
                color: context.primaryColor,
              ),
            ],
          ),
          if (isDone) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF34C759).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                successText,
                style: const TextStyle(
                  color: Color(0xFF34C759),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    final isEnabled = onPressed != null;
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEnabled
              ? color.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.08),
          border: Border.all(
            color: isEnabled
                ? color.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.15),
          ),
        ),
        child: Icon(
          icon,
          color: isEnabled ? color : Colors.grey.withValues(alpha: 0.4),
          size: 22,
        ),
      ),
    );
  }

  // ─── iOS Toggle Switch ──────

  Widget _buildIOSToggle(String text, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFF34C759).withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: context.isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) => onChanged(v),
            activeColor: const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }

  // ─── Data Methods ──────

  bool _canCompleteStep(String step) {
    if (step == 'الطواف') {
      return _tawafCircuits == 7 && _isPrayedAtMaqam && _isDrunkZamzam;
    }
    if (step == 'السعي') {
      return _saiLaps == 7;
    }
    return true;
  }

  List<String> _getGuidelinePoints(String step) {
    String keyPrefix = '';
    int count = 0;
    switch (step) {
      case 'الإحرام':
        keyPrefix = 'guide_ihram';
        count = 6;
        break;
      case 'دخول المسجد الحرام':
        keyPrefix = 'guide_entrance';
        count = 3;
        break;
      case 'الطواف':
        keyPrefix = 'guide_tawaf';
        count = 5;
        break;
      case 'السعي':
        keyPrefix = 'guide_sai';
        count = 5;
        break;
      case 'التقصير أو الحلق والتحلل':
        keyPrefix = 'guide_tahlul';
        count = 3;
        break;
    }

    if (keyPrefix.isEmpty) return ['Follow the Sunnah.'];
    return List.generate(count, (i) => '${keyPrefix}_${i + 1}'.tr());
  }

  String _getDuaArabic(String step) {
    switch (step) {
      case 'الإحرام':
        return 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً. لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لاَ شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لاَ شَرِيكَ لَكَ.';
      case 'الطواف':
        return 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ.';
      case 'السعي':
        return 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ فَلَا جُنَاحَ عَلَيْهِ أَنْ يَطَّوَّفَ بِهِمَا وَمَنْ تَطَوَّعَ خَيْرًا فَإِنَّ اللَّهَ شَاكِرٌ عَلِيمٌ.';
      default:
        return '';
    }
  }

  String _getDuaTranslation(String step) {
    String key = '';
    switch (step) {
      case 'الإحرام':
        key = 'dua_ihram_trans';
        break;
      case 'الطواف':
        key = 'dua_tawaf_trans';
        break;
      case 'السعي':
        key = 'dua_sai_trans';
        break;
    }
    if (key.isEmpty) return '';
    return key.tr();
  }

  // ─── Bottom Sheets (iOS style) ──────

  void _showIshtiratBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: context.isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'دعاء الاشتراط',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: context.onSurfaceColor,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Text(
                      UmrahDuas.ishtiratInfo,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: context.isDark
                            ? Colors.grey[300]
                            : Colors.grey[700],
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    DuaWidget(
                      arabicText: UmrahDuas.ishtiratFull,
                      translation: UmrahDuas.ishtirat.translation ?? '',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'تقوله عند نية الدخول في الإحرام',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDuasBottomSheet(BuildContext context, String step) {
    final duas = step == 'الإحرام' ? UmrahDuas.tawafSaiDuas : UmrahDuas.saiDuas;
    final categories = duas.map((e) => e.category).toSet().toList();

    String title;
    switch (step) {
      case 'الإحرام':
        title = 'أدعية الطواف والسعي الثابتة';
        break;
      case 'السعي':
        title = 'أدعية السعي الشاملة';
        break;
      default:
        title = 'أدعية الطواف الشاملة';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => DefaultTabController(
          length: categories.length,
          child: Container(
            decoration: BoxDecoration(
              color: context.isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.onSurfaceColor,
                    ),
                  ),
                ),
                // Tab bar
                TabBar(
                  isScrollable: true,
                  labelColor: context.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: context.primaryColor,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  tabs: categories.map((cat) => Tab(text: cat)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: categories.map((cat) {
                      final catDuas = duas
                          .where((d) => d.category == cat)
                          .toList();
                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: catDuas.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final dua = catDuas[index];
                          return DuaWidget(
                            arabicText: dua.arabic,
                            translation: dua.translation ?? '',
                            source: dua.source,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCompletionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'accept_title'.tr(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.onSurfaceColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'accept_message'.tr(),
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'close'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Ring Painter (Activity Ring) ──────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 10.0;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [ringColor.withValues(alpha: 0.6), ringColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.ringColor != ringColor;
}
