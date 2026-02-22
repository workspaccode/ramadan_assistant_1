import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/theme/ramadan_theme_extension.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/bloc/tasbih_bloc.dart';

class TasbihView extends StatelessWidget {
  const TasbihView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;
    final today = HijriCalendar.now();
    final isRamadan = today.hMonth == 9;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('tasbih_title'.tr()),
        leading: GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Icon(Icons.arrow_back, color: theme.textPrimary),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage(
                      'assets/image/islamic_pattern_premium_gold_1771758633652.png',
                    ),
                    fit: BoxFit.cover,
                    opacity: 0.05,
                  ),
                ),
                child: Stack(
                  children: [
                    // Ramadan Background Ornaments
                    if (isRamadan) ...[
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Opacity(
                          opacity: 0.1,
                          child: SvgPicture.asset(
                            'assets/ra3.svg',
                            width: 200,
                            height: 200,
                            colorFilter: ColorFilter.mode(
                              theme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Main Content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: BlocBuilder<TasbihBloc, TasbihState>(
                          builder: (context, state) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    _buildDhikrCard(context, state),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildTasbihCounter(context, state),
                                Column(
                                  children: [
                                    _buildProgressIndicator(context, state),
                                    const SizedBox(height: 40),
                                    _buildActionButtons(context),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ],
                            );
                          },
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

  Widget _buildRamadanHeader(BuildContext context, bool isRamadan) {
    final theme = context.ramadanTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new, color: theme.textPrimary),
              ),
              Text(
                'tasbih_title'.tr(),
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 48), // Spacer for balance
            ],
          ),
          if (isRamadan) ...[
            const SizedBox(height: 8),
            Text(
              'وَذَكِرُوا اللَّهَ كَثِيرًا لَعَلَّكُمْ تُفْلِحُونَ',
              style: TextStyle(
                color: theme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Amiri',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDhikrCard(BuildContext context, TasbihState state) {
    final theme = context.ramadanTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            state.currentDhikr.tr(),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${'target'.tr()}: ${state.target}',
              style: TextStyle(
                color: theme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasbihCounter(BuildContext context, TasbihState state) {
    final theme = context.ramadanTheme;
    final isCompleted = state.count >= state.target;

    return GestureDetector(
      onTap: () => context.read<TasbihBloc>().add(IncrementCounter()),
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.cardSurface,
          border: Border.all(
            color: isCompleted ? theme.success : theme.primary,
            width: 8,
          ),
          boxShadow: [
            BoxShadow(
              color: (isCompleted ? theme.success : theme.primary).withValues(
                alpha: 0.2,
              ),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 20),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Text(
                  '${state.count}',
                  key: ValueKey(state.count),
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 84,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isCompleted)
                Icon(Icons.check_circle, color: theme.success, size: 32)
              else
                Text(
                  'tap_to_count'.tr(),
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, TasbihState state) {
    final theme = context.ramadanTheme;
    final progress = (state.count / state.target).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'progress'.tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.primary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? theme.success : theme.primary,
            ),
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = context.ramadanTheme;
    return Row(
      children: [
        Expanded(
          child: _buildModernActionButton(
            context,
            icon: Icons.refresh_rounded,
            label: 'reset'.tr(),
            color: theme.warning,
            onPressed: () => _showResetDialog(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildModernActionButton(
            context,
            icon: Icons.list_alt_rounded,
            label: 'dhikr_list'.tr(),
            color: theme.primary,
            onPressed: () => _showDhikrPicker(context),
          ),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context) {
    final theme = context.ramadanTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardSurface,
        title: Text('reset_confirm'.tr()),
        content: Text('reset_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(color: theme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<TasbihBloc>().add(ResetCounter());
              Navigator.pop(context);
            },
            child: Text('reset'.tr(), style: TextStyle(color: theme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final theme = context.ramadanTheme;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.borderColor, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDhikrPicker(BuildContext context) {
    final theme = context.ramadanTheme;
    final ramadanDhikrs = [
      {'id': 'SubhanAllah', 'target': 33, 'reward': 'reward_subhanallah'},
      {'id': 'Alhamdulillah', 'target': 33, 'reward': 'reward_alhamdulillah'},
      {'id': 'Allahu Akbar', 'target': 33, 'reward': 'reward_allahuakbar'},
      {
        'id': 'La ilaha illallah',
        'target': 100,
        'reward': 'reward_lailahaillallah',
      },
      {
        'id': 'Astaghfirullah',
        'target': 100,
        'reward': 'reward_astaghfirullah',
      },
      {'id': 'salawat', 'target': 100, 'reward': 'reward_salawat'},
      {
        'id': 'subhanallah_wabihamdihi',
        'target': 100,
        'reward': 'reward_wabihamdihi',
      },
      {'id': 'lahawla', 'target': 100, 'reward': 'reward_lahawla'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          _DhikrSelectionSheet(dhikrs: ramadanDhikrs, theme: theme),
    );
  }
}

class _DhikrSelectionSheet extends StatefulWidget {
  final List<Map<String, dynamic>> dhikrs;
  final RamadanThemeExtension theme;

  const _DhikrSelectionSheet({required this.dhikrs, required this.theme});

  @override
  State<_DhikrSelectionSheet> createState() => _DhikrSelectionSheetState();
}

class _DhikrSelectionSheetState extends State<_DhikrSelectionSheet> {
  String? _selectedDhikrId;
  int _selectedTarget = 33;
  final TextEditingController _customTargetController = TextEditingController();
  bool _isCustomTarget = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.textDim.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'select_dhikr'.tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: theme.textDim),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 16),
                ...widget.dhikrs.map((d) {
                  final isSelected = _selectedDhikrId == d['id'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => setState(() => _selectedDhikrId = d['id']),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.primary.withValues(alpha: 0.1)
                              : theme.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? theme.primary
                                : theme.borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (d['id'] as String).tr(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: theme.textPrimary,
                                      fontFamily: 'Amiri',
                                    ),
                                  ),
                                  if (d['reward'] != null)
                                    Text(
                                      (d['reward'] as String).tr(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: theme.primary),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 32),
                Text(
                  'select_target'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [33, 99, 100, 1000].map((count) {
                    final isSelected =
                        !_isCustomTarget && _selectedTarget == count;
                    return InkWell(
                      onTap: () => setState(() {
                        _isCustomTarget = false;
                        _selectedTarget = count;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.primary : theme.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.borderColor),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : theme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () => setState(() => _isCustomTarget = true),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCustomTarget
                          ? theme.primary.withValues(alpha: 0.1)
                          : theme.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isCustomTarget
                            ? theme.primary
                            : theme.borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: _isCustomTarget
                              ? theme.primary
                              : theme.textDim,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _isCustomTarget
                              ? TextField(
                                  controller: _customTargetController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'custom_target_hint'.tr(),
                                    border: InputBorder.none,
                                    fillColor: Colors.transparent,
                                  ),
                                  style: TextStyle(
                                    color: theme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onChanged: (val) {
                                    final n = int.tryParse(val);
                                    if (n != null) _selectedTarget = n;
                                  },
                                )
                              : Text(
                                  'custom_target'.tr(),
                                  style: TextStyle(
                                    color: theme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _selectedDhikrId == null
                      ? null
                      : () {
                          context.read<TasbihBloc>().add(
                            ChangeDhikr(_selectedDhikrId!, _selectedTarget),
                          );
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'start_tasbih'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
