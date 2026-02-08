import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/presentation/blocs/language_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/language_event.dart';
import 'package:ramadan_assistant/presentation/blocs/language_state.dart';
import 'package:ramadan_assistant/presentation/blocs/settings_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/settings_event.dart';
import 'package:ramadan_assistant/presentation/blocs/settings_state.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_event.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_state.dart';
import 'package:ramadan_assistant/presentation/screens/adhan_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsView();
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings_title'.tr())),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading || state is SettingsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoaded) {
            return _buildSettingsContent(context, state);
          } else if (state is SettingsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, SettingsLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader(context, 'method'.tr()),
        const SizedBox(height: 10),
        _buildMethodSelector(context, state),
        const SizedBox(height: 15),
        _buildMadhabSelector(context, state),
        const SizedBox(height: 30),
        _buildSectionHeader(context, 'iqama_settings'.tr()),
        const SizedBox(height: 10),
        _buildIqamaSettings(context, state),
        const SizedBox(height: 30),
        _buildSectionHeader(context, 'dark_mode'.tr()),
        const SizedBox(height: 10),
        _buildDarkModeToggle(context),
        const SizedBox(height: 30),
        _buildSectionHeader(context, 'language'.tr()),
        const SizedBox(height: 10),
        _buildLanguageSelector(context),
        const SizedBox(height: 30),
        _buildSectionHeader(context, 'about'.tr()),
        const SizedBox(height: 10),
        _buildAboutCard(context),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildMethodSelector(BuildContext context, SettingsLoaded state) {
    final methods = [
      {'id': 'muslimWorldLeague', 'name': 'method_muslimWorldLeague'.tr()},
      {'id': 'egyptian', 'name': 'method_egyptian'.tr()},
      {'id': 'karachi', 'name': 'method_karachi'.tr()},
      {'id': 'ummAlQura', 'name': 'method_ummAlQura'.tr()},
      {'id': 'dubai', 'name': 'method_dubai'.tr()},
      {'id': 'qatar', 'name': 'method_qatar'.tr()},
      {'id': 'kuwait', 'name': 'method_kuwait'.tr()},
      {'id': 'singapore', 'name': 'method_singapore'.tr()},
      {'id': 'northAmerica', 'name': 'method_northAmerica'.tr()},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  'method'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: state.calculationMethod,
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
              items: methods
                  .map(
                    (m) => DropdownMenuItem(
                      value: m['id'],
                      child: Text(
                        m['name']!,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(
                    UpdateCalculationMethod(value),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMadhabSelector(BuildContext context, SettingsLoaded state) {
    final madhabs = [
      {'id': 'shafi', 'name': 'madhab_shafi'.tr()},
      {'id': 'hanafi', 'name': 'madhab_hanafi'.tr()},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mosque, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  'madhab'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...madhabs.map(
              (m) => RadioListTile<String>(
                title: Text(m['name']!),
                value: m['id']!,
                groupValue: state.madhab,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) {
                  if (value != null) {
                    context.read<SettingsBloc>().add(UpdateMadhab(value));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIqamaSettings(BuildContext context, SettingsLoaded state) {
    final systems = [
      {'id': 'manual', 'name': 'system_manual'.tr()},
      {'id': 'preset', 'name': 'system_preset'.tr()},
    ];
    final presets = [
      {'id': 'saudi', 'name': 'preset_saudi'.tr()},
      {'id': 'egypt', 'name': 'preset_egypt'.tr()},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  'iqama_system'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: state.iqamaSystem,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'iqama_system'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: systems
                  .map(
                    (s) => DropdownMenuItem(
                      value: s['id'],
                      child: Text(s['name']!),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(UpdateIqamaSystem(value));
                }
              },
            ),
            const SizedBox(height: 20),
            if (state.iqamaSystem == 'manual') ...[
              Row(
                children: [
                  Text(
                    'manual_delay'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${state.iqamaDelayMinutes} ${'min'.tr()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: state.iqamaDelayMinutes.toDouble(),
                min: 5,
                max: 30,
                divisions: 5,
                activeColor: AppTheme.primaryColor,
                onChanged: (value) => context.read<SettingsBloc>().add(
                  UpdateIqamaDelay(value.toInt()),
                ),
              ),
            ] else ...[
              DropdownButtonFormField<String>(
                initialValue: state.iqamaPreset,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'iqama_preset'.tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: presets
                    .map(
                      (p) => DropdownMenuItem(
                        value: p['id'],
                        child: Text(p['name']!),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<SettingsBloc>().add(UpdateIqamaPreset(value));
                  }
                },
              ),
              const SizedBox(height: 10),
              Text(
                'iqama_info'.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        bool isDark = false;
        if (state is ThemeLoaded) {
          isDark = state.isDarkMode;
        }
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SwitchListTile(
            title: Row(
              children: [
                const Icon(Icons.dark_mode, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  'dark_mode'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            value: isDark,
            activeThumbColor: AppTheme.secondaryColor,
            onChanged: (value) =>
                context.read<ThemeBloc>().add(ToggleDarkMode(value)),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final langs = [
      {'id': 'ar', 'name': 'العربية', 'icon': '🇸🇦'},
      {'id': 'en', 'name': 'English', 'icon': '🇺🇸'},
      {'id': 'ur', 'name': 'اردو', 'icon': '🇵🇰'},
    ];

    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String languageCode = 'ar';
        if (state is LanguageLoaded) {
          languageCode = state.languageCode;
        }
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.language, color: AppTheme.primaryColor),
                    const SizedBox(width: 10),
                    Text(
                      'language'.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  initialValue: languageCode,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                  ),
                  items: langs
                      .map(
                        (l) => DropdownMenuItem(
                          value: l['id'],
                          child: Row(
                            children: [
                              Text(
                                l['icon']!,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l['name']!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<LanguageBloc>().add(UpdateLanguage(value));
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  'app_name'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${'version'.tr()} 1.0.0',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text('app_desc'.tr(), style: const TextStyle(height: 1.5)),
            const SizedBox(height: 15),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AdhanScreen(prayerName: 'Test Adhan'),
                  ),
                ),
                icon: const Icon(Icons.play_circle_fill),
                label: Text('test_adhan'.tr()),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
