import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/presentation/blocs/tasbih_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/tasbih_event.dart';
import 'package:ramadan_assistant/presentation/blocs/tasbih_state.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TasbihBloc(),
      child: const TasbihView(),
    );
  }
}

class TasbihView extends StatelessWidget {
  const TasbihView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('tasbih_title'.tr())),
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
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${'target'.tr()}: ${state.target}',
                  style: const TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 18,
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
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
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
            backgroundColor: AppTheme.secondaryColor,
            foregroundColor: AppTheme.primaryColor,
            minimumSize: const Size(60, 60),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'select_dhikr'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...dhikrs.map(
                (d) => ListTile(
                  title: Text((d['id'] as String).tr()),
                  subtitle: Text('${'target'.tr()}: ${d['target']}'),
                  onTap: () {
                    context.read<TasbihBloc>().add(
                      ChangeDhikr(d['id'] as String, d['target'] as int),
                    );
                    Navigator.pop(bottomSheetContext);
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
