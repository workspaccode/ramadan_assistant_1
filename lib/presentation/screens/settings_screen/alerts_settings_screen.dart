import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen/bloc/settings_screen_bloc.dart';

class AlertsSettingsScreen extends StatelessWidget {
  const AlertsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsScreenBloc, SettingsScreenState>(
      builder: (context, state) {
        if (state is! SettingsScreenLoaded) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        return Scaffold(
          bottomNavigationBar: const SakinaBottomBar(selectedIndex: 1),
          appBar: AppBar(
            title: Text(
              'manage_alerts'.tr(),
              style: TextStyle(
                color: context.isDark ? Colors.white : Colors.black,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: ListView(
              children: [
                SakinaSettingsSection(
                  header: Text('prayer_alerts'.tr().toUpperCase()),
                  children: [
                    _buildSwitchTile(
                      context,
                      'adhan_alerts'.tr(),
                      'adhan_alerts_desc'.tr(),
                      state.adhanEnabled,
                      (val) => context.read<SettingsScreenBloc>().add(
                        ToggleAdhanSetting(val),
                      ),
                    ),
                    _buildSwitchTile(
                      context,
                      'iqama_alerts'.tr(),
                      'iqama_alerts_desc'.tr(),
                      state.iqamaEnabled,
                      (val) => context.read<SettingsScreenBloc>().add(
                        ToggleIqamaSetting(val),
                      ),
                    ),
                  ],
                ),
                SakinaSettingsSection(
                  header: Text('reminders'.tr().toUpperCase()),
                  children: [
                    _buildSwitchTile(
                      context,
                      'dhikr_reminders'.tr(),
                      'dhikr_reminders_desc'.tr(),
                      state.dhikrEnabled,
                      (val) => context.read<SettingsScreenBloc>().add(
                        ToggleDhikrSetting(val),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'alerts_settings_footer'.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SakinaSettingsTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: context.primaryColor,
      ),
    );
  }
}
