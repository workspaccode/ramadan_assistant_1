import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/data/models/wird_plan.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/wird_screen/bloc/wird_event.dart';

class WirdSelectionView extends StatefulWidget {
  const WirdSelectionView({super.key});

  @override
  State<WirdSelectionView> createState() => _WirdSelectionViewState();
}

class _WirdSelectionViewState extends State<WirdSelectionView> {
  WirdType _selectedType = WirdType.khatma;
  int _selectedValue = 1;

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'wird_plan_selection'.tr(),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildPlanOption(
            context,
            type: WirdType.khatma,
            title: 'wird_khatma_plan'.tr(),
            description: 'wird_khatmas'.tr(args: ['$_selectedValue']),
            icon: Icons.auto_stories,
            values: [1, 2, 3, 5, 10],
          ),
          const SizedBox(height: 16),
          _buildPlanOption(
            context,
            type: WirdType.pagesPerPrayer,
            title: 'wird_pages_prayer_plan'.tr(),
            description: 'wird_pages_per_prayer'.tr(args: ['$_selectedValue']),
            icon: Icons.mosque,
            values: [1, 2, 3, 4, 5, 6],
          ),
          const SizedBox(height: 16),
          _buildPlanOption(
            context,
            type: WirdType.juzPerDay,
            title: 'wird_juz_plan'.tr(),
            description: 'wird_juz_per_day'.tr(args: ['$_selectedValue']),
            icon: Icons.menu_book,
            values: [1, 2, 3],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              context.read<WirdBloc>().add(
                SetWirdPlan(
                  WirdPlan(type: _selectedType, value: _selectedValue),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'wird_start_plan'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPlanOption(
    BuildContext context, {
    required WirdType type,
    required String title,
    required String description,
    required IconData icon,
    required List<int> values,
  }) {
    final theme = context.ramadanTheme;
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedValue = values.first;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withValues(alpha: 0.1)
              : theme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primary : theme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primary
                        : theme.textDim.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : theme.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isSelected ? description : '',
                        style: TextStyle(
                          color: theme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected) Icon(Icons.check_circle, color: theme.primary),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: values.map((v) {
                    final isValSelected = _selectedValue == v;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text('$v'),
                        onPressed: () {
                          setState(() => _selectedValue = v);
                        },
                        backgroundColor: isValSelected
                            ? theme.primary
                            : theme.cardSurface,
                        labelStyle: TextStyle(
                          color: isValSelected
                              ? Colors.white
                              : theme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
