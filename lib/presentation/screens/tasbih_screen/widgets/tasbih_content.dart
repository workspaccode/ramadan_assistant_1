import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/tasbih_screen/bloc/tasbih_bloc.dart';

class TasbihView extends StatelessWidget {
  const TasbihView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text('tasbih_title'.tr()),
        backgroundColor: context.backgroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<TasbihBloc, TasbihState>(
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.currentDhikr.tr(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: context.locale.languageCode == 'en'
                        ? null
                        : 'Amiri',
                    color: context.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '${'target'.tr()}: ${state.target}',
                  style: TextStyle(
                    color: context.secondaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () =>
                      context.read<TasbihBloc>().add(IncrementCounter()),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: context.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${state.count}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      context,
                      icon: Icons.refresh,
                      label: 'reset'.tr(),
                      onPressed: () =>
                          context.read<TasbihBloc>().add(ResetCounter()),
                    ),
                    const SizedBox(width: 30),
                    _buildActionButton(
                      context,
                      icon: Icons.list,
                      label: 'dhikr_list'.tr(),
                      onPressed: () => _showDhikrPicker(context),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
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
    final dhikrs = [
      {'id': 'SubhanAllah', 'target': 33},
      {'id': 'Alhamdulillah', 'target': 33},
      {'id': 'Allahu Akbar', 'target': 33},
      {'id': 'La ilaha illallah', 'target': 100},
      {'id': 'Astaghfirullah', 'target': 100},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'select_dhikr'.tr(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: dhikrs.length,
                  itemBuilder: (context, index) {
                    final d = dhikrs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      color: context.secondaryColor.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          (d['id'] as String).tr(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('${'target'.tr()}: ${d['target']}'),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: context.primaryColor,
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
