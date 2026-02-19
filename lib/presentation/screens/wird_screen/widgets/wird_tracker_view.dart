import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/theme/ramadan_theme_extension.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_event.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_state.dart';

class WirdTrackerView extends StatelessWidget {
  final WirdPlanActive state;

  const WirdTrackerView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProgressCard(context, theme),
          const SizedBox(height: 24),
          _buildActionCard(context, theme),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              _showResetDialog(context);
            },
            icon: Icon(Icons.refresh, color: theme.textDim),
            label: Text(
              'wird_change_plan'.tr(),
              style: TextStyle(color: theme.textDim),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, RamadanThemeExtension theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'wird_total_progress'.tr(),
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(state.progress * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 12,
              backgroundColor: theme.textDim.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'wird_page_of'.tr(
              args: [
                '${state.completedPages}',
                '${state.plan.totalTargetPages}',
              ],
            ),
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, RamadanThemeExtension theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: theme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'wird_daily_target'.tr(
                    args: ['${state.plan.dailyTargetPages}'],
                  ),
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showLogDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'wird_log_progress'.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogDialog(BuildContext context) {
    final theme = context.ramadanTheme;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.background,
        title: Text('wird_log_progress'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('wird_pages_read'.tr()),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: '0',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                context.read<WirdBloc>().add(UpdateWirdProgress(val));
              }
              Navigator.pop(context);
            },
            child: Text('save'.tr()),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    final theme = context.ramadanTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.background,
        title: Text('reset_confirm'.tr()),
        content: Text('reset_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              context.read<WirdBloc>().add(ResetWirdProgress());
              Navigator.pop(context);
            },
            child: Text('reset'.tr(), style: TextStyle(color: theme.error)),
          ),
        ],
      ),
    );
  }
}
