import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/theme/ramadan_theme_extension.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/bloc/tasbih_bloc.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

class TasbihView extends StatefulWidget {
  const TasbihView({super.key, this.sessions});
  final Stream<List<TasbihSession>>? sessions;
  @override
  State<TasbihView> createState() => _TasbihViewState();
}

class _TasbihViewState extends State<TasbihView> {
  int _historyRetry = 0;
  late Stream<List<TasbihSession>> _sessions =
      widget.sessions ??
      context
          .read<AppDatabase>()
          .select(context.read<AppDatabase>().tasbihSessions)
          .watch();

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !AppShellScope.contains(context),
        title: Text(context.loc.ui_tasbih_activity),
        actions: [
          IconButton(
            tooltip: 'reset'.tr(),
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () => _showResetDialog(context),
          ),
        ],
      ),
      bottomNavigationBar: const SakinaBottomBar(selectedIndex: 3),
      body: BlocBuilder<TasbihBloc, TasbihState>(
        builder: (context, state) {
          final progress = state.target <= 0
              ? 0.0
              : (state.count / state.target).clamp(0.0, 1.0);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              SakinaCard(
                child: Column(
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SakinaBadge(
                          context.loc.ui_session,
                          icon: Icons.loop_rounded,
                        ),
                        ...[33, 100].map(
                          (target) => ChoiceChip(
                            label: Text('$target'),
                            labelStyle: context.textTheme.labelMedium?.copyWith(
                              color: state.target == target
                                  ? context.onPrimaryColor
                                  : context.primaryColor,
                            ),
                            selected: state.target == target,
                            onSelected: (_) => context.read<TasbihBloc>().add(
                              ChangeTarget(target),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.loc.ui_selected_dhikr,
                      style: context.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.currentDhikr.tr(),
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineLarge?.copyWith(
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final diameter = math.min(236.0, constraints.maxWidth);
                        return Semantics(
                          button: true,
                          label: 'tap_to_count'.tr(),
                          value: '${state.count} / ${state.target}',
                          onTap: () => context.read<TasbihBloc>().add(
                            IncrementCounter(),
                          ),
                          excludeSemantics: true,
                          child: SizedBox(
                            width: diameter,
                            height: diameter,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 8,
                                    backgroundColor: SakinaColors.mint(context),
                                    valueColor: AlwaysStoppedAnimation(
                                      theme.accent,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Material(
                                    color: SakinaColors.hero(context),
                                    shape: const CircleBorder(),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () => context
                                          .read<TasbihBloc>()
                                          .add(IncrementCounter()),
                                      child: SizedBox.expand(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'tap_to_count'.tr(),
                                                style: context
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: const Color(
                                                        0xFFCCE8DB,
                                                      ),
                                                    ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    '${state.count}',
                                                    style: const TextStyle(
                                                      fontSize: 72,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '${'target'.tr()} ${state.target}',
                                                style: context
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: const Color(
                                                        0xFFCCE8DB,
                                                      ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      children: [
                        Text(
                          '${context.loc.ui_remaining}: ${math.max(0, state.target - state.count)}',
                          style: context.textTheme.bodySmall,
                        ),
                        SakinaBadge('${(progress * 100).round()}%', gold: true),
                      ],
                    ),
                    if (state is TasbihSaveFailed) ...[
                      const SizedBox(height: 12),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          context.loc.ui_tasbih_save_failed,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: theme.error,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            context.read<TasbihBloc>().add(RetryTasbihSave()),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text('retry'.tr()),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Divider(color: theme.borderColor),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: TasbihBloc.defaultDhikrs
                          .take(4)
                          .map(
                            (name) => ChoiceChip(
                              label: Text(
                                name.tr(),
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: state.currentDhikr == name
                                      ? context.onPrimaryColor
                                      : context.primaryColor,
                                ),
                              ),
                              selected: state.currentDhikr == name,
                              onSelected: (_) => context.read<TasbihBloc>().add(
                                ChangeDhikr(name, state.target),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => _showDhikrPicker(context),
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: Text('dhikr_list'.tr()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SakinaSectionTitle(
                context.loc.ui_activity_history,
                icon: Icons.bar_chart_rounded,
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<TasbihSession>>(
                key: ValueKey(_historyRetry),
                stream: _sessions,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SakinaCard(
                      child: Column(
                        children: [
                          Text('something_went_wrong'.tr()),
                          TextButton.icon(
                            onPressed: () => setState(() {
                              _historyRetry++;
                              _sessions =
                                  widget.sessions ??
                                  context
                                      .read<AppDatabase>()
                                      .select(
                                        context
                                            .read<AppDatabase>()
                                            .tasbihSessions,
                                      )
                                      .watch();
                            }),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text('retry'.tr()),
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  final sessions = snapshot.data!;
                  final total = sessions.fold<int>(
                    0,
                    (sum, item) => sum + item.count,
                  );
                  final completed = sessions
                      .where((item) => item.completedAt != null)
                      .length;
                  return Column(
                    children: [
                      _stat(
                        context,
                        'tasbih_total'.tr(),
                        total,
                        Icons.all_inclusive_rounded,
                      ),
                      const SizedBox(height: 12),
                      _stat(
                        context,
                        context.loc.ui_total_sessions,
                        sessions.length,
                        Icons.history_rounded,
                      ),
                      const SizedBox(height: 12),
                      _stat(
                        context,
                        context.loc.ui_completed_sessions,
                        completed,
                        Icons.emoji_events_outlined,
                        gold: true,
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(
    BuildContext context,
    String title,
    int value,
    IconData icon, {
    bool gold = false,
  }) => SakinaCard(
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text('$value', style: context.textTheme.headlineLarge),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: gold
                ? SakinaColors.gold(context).withValues(alpha: .25)
                : SakinaColors.mint(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: gold ? context.ramadanTheme.secondary : context.primaryColor,
          ),
        ),
      ],
    ),
  );

  void _showResetDialog(BuildContext context) {
    final theme = context.ramadanTheme;
    final bloc = context.read<TasbihBloc>();
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
              bloc.add(ResetCounter());
              Navigator.pop(context);
            },
            child: Text('reset'.tr(), style: TextStyle(color: theme.error)),
          ),
        ],
      ),
    );
  }

  void _showDhikrPicker(BuildContext context) {
    final theme = context.ramadanTheme;
    final bloc = context.read<TasbihBloc>();
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
      builder: (context) => BlocProvider.value(
        value: bloc,
        child: _DhikrSelectionSheet(
          dhikrs: ramadanDhikrs,
          theme: theme,
          initialDhikr: bloc.state.currentDhikr,
          initialTarget: bloc.state.target,
        ),
      ),
    );
  }
}

class _DhikrSelectionSheet extends StatefulWidget {
  final List<Map<String, dynamic>> dhikrs;
  final RamadanThemeExtension theme;
  final String initialDhikr;
  final int initialTarget;

  const _DhikrSelectionSheet({
    required this.dhikrs,
    required this.theme,
    required this.initialDhikr,
    required this.initialTarget,
  });

  @override
  State<_DhikrSelectionSheet> createState() => _DhikrSelectionSheetState();
}

class _DhikrSelectionSheetState extends State<_DhikrSelectionSheet> {
  String? _selectedDhikrId;
  int _selectedTarget = 33;
  final TextEditingController _customTargetController = TextEditingController();
  bool _isCustomTarget = false;

  @override
  void initState() {
    super.initState();
    _selectedDhikrId = widget.initialDhikr;
    _selectedTarget = widget.initialTarget;
    _isCustomTarget = ![33, 99, 100, 1000].contains(_selectedTarget);
    _customTargetController.text = '$_selectedTarget';
  }

  @override
  void dispose() {
    _customTargetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Container(
          height:
              (MediaQuery.sizeOf(context).height * 0.85 -
                      MediaQuery.viewInsetsOf(context).bottom)
                  .clamp(240.0, double.infinity),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'select_dhikr'.tr(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'cancel'.tr(),
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
                          onTap: () => setState(() {
                            _selectedDhikrId = d['id'];
                            if (!_isCustomTarget) {
                              _selectedTarget = d['target'] as int;
                            }
                          }),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (d['id'] as String).tr(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: theme.textPrimary,
                                          fontFamily: 'Cairo',
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
                                  Icon(
                                    Icons.check_circle,
                                    color: theme.primary,
                                  ),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                              color: isSelected
                                  ? theme.primary
                                  : theme.cardSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.borderColor),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: isSelected
                                    ? context.onPrimaryColor
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
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
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
                                        setState(
                                          () => _selectedTarget = n ?? 0,
                                        );
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: ElevatedButton(
                  onPressed:
                      _selectedDhikrId == null ||
                          (_isCustomTarget && _selectedTarget <= 0)
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.onPrimaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
