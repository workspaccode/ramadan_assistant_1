import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/test_service.dart';
import 'package:ramadan_assistant/presentation/blocs/language_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/language_event.dart';
import 'package:ramadan_assistant/presentation/blocs/language_state.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_event.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_state.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen/alerts_settings_screen.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen/bloc/settings_screen_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen/widgets/settings_dialogs.dart';
import 'package:ramadan_assistant/presentation/screens/update_screen/update_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

class SettingsScreenContent extends StatelessWidget {
  const SettingsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final today = HijriCalendar.now();
    final isRamadan = today.hMonth == 9;

    return BlocBuilder<SettingsScreenBloc, SettingsScreenState>(
      builder: (context, state) {
        return Scaffold(
          bottomNavigationBar: const SakinaBottomBar(selectedIndex: 1),
          backgroundColor: context.backgroundColor,
          body: Container(
            decoration: BoxDecoration(
              gradient: isRamadan
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF2E7D32).withValues(alpha: 0.05),
                        const Color(0xFF4CAF50).withValues(alpha: 0.02),
                      ],
                    )
                  : null,
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildRamadanAppBar(context, isRamadan),
                if (state is SettingsScreenLoaded)
                  SliverSafeArea(
                    top: false,
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // _buildRamadanCard(context, isRamadan),
                        _buildLocationSection(context, state),
                        _buildAppearanceSection(context, state),
                        _buildAppIconSection(context, state),
                        _buildNotificationsSection(context, state),
                        _buildHijriSection(context, state),
                        _buildPrayerSection(context, state),
                        _buildIqamaSection(context, state),
                        _buildAudioSection(context, state),
                        _buildAdminSection(context, state),
                        // Developer-only test tiles must never appear in release builds
                        if (kDebugMode) _buildTestSection(context),
                        _buildFooter(context),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  )
                else if (state is SettingsScreenError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: SakinaCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.settings_outlined,
                                size: 32,
                                color: context.primaryColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'something_went_wrong'.tr(),
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: Text('retry'.tr()),
                                onPressed: () => context
                                    .read<SettingsScreenBloc>()
                                    .add(LoadSettings()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverFillRemaining(
                    child: Center(child: _buildLoadingState()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRamadanAppBar(BuildContext context, bool isRamadan) {
    return SliverAppBar(
      title: Text('settings_title'.tr()),
      centerTitle: true,
      pinned: true,
      backgroundColor: context.backgroundColor,
    );
  }

  // Widget _buildRamadanCard(BuildContext context, bool isRamadan) { ... }

  Widget _buildLocationSection(
    BuildContext context,
    SettingsScreenLoaded state,
  ) {
    return SakinaSettingsSection(
      header: Text('location'.tr().toUpperCase()),
      children: [
        SakinaSettingsTile(
          title: Text('current_location'.tr()),
          subtitle: Text(
            '${state.city ?? 'unknown'.tr()}, ${state.country ?? ''}',
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(Icons.location_on_outlined, size: 20),
            onPressed: () =>
                context.read<SettingsScreenBloc>().add(RefreshLocation()),
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    SettingsScreenLoaded state,
  ) {
    return SakinaSettingsSection(
      header: Text('appearance'.tr().toUpperCase()),
      children: [
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            final isDarkMode = themeState is ThemeLoaded
                ? themeState.isDarkMode
                : false;
            return _buildSwitchTile(
              context,
              'dark_mode'.tr(),
              'enable_dark_theme'.tr(),
              isDarkMode,
              (value) => context.read<ThemeBloc>().add(ToggleDarkMode(value)),
            );
          },
        ),
        _buildLanguageTile(context),
        _buildColorPaletteTile(context, state),
        _buildFontSizeSlider(context, state),
      ],
    );
  }

  Widget _buildColorPaletteTile(
    BuildContext context,
    SettingsScreenLoaded state,
  ) {
    return SakinaSettingsTile(
      title: Text('color_palette'.tr()),
      additionalInfo: Text((state.colorPaletteId ?? 'default').tr()),
      trailing: const Icon(Icons.chevron_right, size: 14),
      onTap: () {
        SettingsDialogs.showColorPaletteDialog(
          context,
          currentPalette: state.colorPaletteId ?? 'default',
          onSelected: (val) {
            context.read<SettingsScreenBloc>().add(
              UpdateSettingsColorPalette(val),
            );
            context.read<ThemeBloc>().add(UpdateColorPalette(val));
          },
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String langCode = 'ar';
        if (state is LanguageLoaded) langCode = state.languageCode;

        final langNames = {'ar': 'العربية', 'en': 'English', 'ur': 'اردو'};

        return SakinaSettingsTile(
          title: Text('language'.tr()),
          additionalInfo: Text(langNames[langCode] ?? langCode),
          trailing: const Icon(Icons.chevron_right, size: 14),
          onTap: () {
            SettingsDialogs.showLanguageDialog(
              context,
              currentLang: langCode,
              onSelected: (val) {
                context.read<LanguageBloc>().add(UpdateLanguage(val));
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAppIconSection(
    BuildContext context,
    SettingsScreenLoaded state,
  ) {
    return SakinaSettingsSection(
      header: Text('app_icon'.tr().toUpperCase()),
      children: [
        _buildDropdownTile(
          context,
          'select_icon'.tr(),
          state.appIcon,
          ['default', 'RamadanIcon'],
          (val) => context.read<SettingsScreenBloc>().add(UpdateAppIcon(val)),
          displayValues: {
            'default': 'Standard'.tr(),
            'RamadanIcon': 'Ramadan Classic'.tr(),
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(
    BuildContext context,
    SettingsScreenLoaded state,
  ) {
    return SakinaSettingsSection(
      header: Text('notifications'.tr().toUpperCase()),
      children: [
        _buildSwitchTile(
          context,
          'global_notifications'.tr(),
          'enable_all_notifications'.tr(),
          state.notificationsEnabled,
          (val) =>
              context.read<SettingsScreenBloc>().add(ToggleNotifications(val)),
        ),
        SakinaSettingsTile(
          title: Text('manage_alerts'.tr()),
          trailing: const Icon(Icons.chevron_right, size: 14),
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<SettingsScreenBloc>(),
                  child: const AlertsSettingsScreen(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHijriSection(BuildContext context, SettingsScreenLoaded state) {
    return SakinaSettingsSection(
      header: Text('hijri_calendar'.tr().toUpperCase()),
      children: [
        _buildDropdownTile(
          context,
          'hijri_adjustment'.tr(),
          state.hijriAdjustment.toString(),
          ['-2', '-1', '0', '1', '2'],
          (val) => context.read<SettingsScreenBloc>().add(
            UpdateHijriAdjustment(int.parse(val)),
          ),
          displayValues: {
            '-2': 'day_adjustment'.tr(args: ['-2']),
            '-1': 'day_adjustment'.tr(args: ['-1']),
            '0': 'day_adjustment'.tr(args: ['0']),
            '1': 'day_adjustment'.tr(args: ['1']),
            '2': 'day_adjustment'.tr(args: ['2']),
          },
          translateOptions: false,
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider(
    BuildContext context,
    SettingsScreenLoaded state,
  ) {
    final theme = context.ramadanTheme;
    return Column(
      children: [
        SakinaSettingsTile(
          title: Text('font_size'.tr()),
          additionalInfo: Text('${(state.fontSizeMultiplier * 100).toInt()}%'),
          subtitle: SizedBox(
            width: double.infinity,
            child: CupertinoSlider(
              value: state.fontSizeMultiplier,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              activeColor: theme.primary,
              onChanged: (val) {
                context.read<SettingsScreenBloc>().add(UpdateFontSize(val));
              },
              onChangeEnd: (val) {
                context.read<ThemeBloc>().add(UpdateFontSizeMultiplier(val));
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              'font_size_preview'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * state.fontSizeMultiplier,
                color: theme.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerSection(BuildContext context, SettingsScreenLoaded state) {
    return SakinaSettingsSection(
      header: Text('prayer_times_title'.tr().toUpperCase()),
      children: [
        _buildDropdownTile(
          context,
          'method'.tr(),
          state.calculationMethod,
          ['muslimWorldLeague', 'ummAlQura', 'egyptian', 'karachi'],
          (val) => context.read<SettingsScreenBloc>().add(
            UpdateCalculationMethod(val),
          ),
        ),
        _buildDropdownTile(
          context,
          'madhab'.tr(),
          state.madhab,
          ['shafi', 'hanafi'],
          (val) => context.read<SettingsScreenBloc>().add(UpdateMadhab(val)),
          displayValues: {
            'shafi': 'madhab_shafi'.tr(),
            'hanafi': 'madhab_hanafi'.tr(),
          },
        ),
      ],
    );
  }

  Widget _buildIqamaSection(BuildContext context, SettingsScreenLoaded state) {
    return SakinaSettingsSection(
      header: Text('iqama_settings'.tr().toUpperCase()),
      children: [
        _buildDropdownTile(
          context,
          'iqama_system'.tr(),
          state.iqamaSystem,
          ['manual', 'preset'],
          (val) =>
              context.read<SettingsScreenBloc>().add(UpdateIqamaSystem(val)),
          displayValues: {
            'manual': 'system_manual'.tr(),
            'preset': 'system_preset'.tr(),
          },
        ),
        if (state.iqamaSystem == 'preset')
          _buildDropdownTile(
            context,
            'iqama_preset'.tr(),
            state.iqamaPreset,
            ['saudi', 'egypt'],
            (val) =>
                context.read<SettingsScreenBloc>().add(UpdateIqamaPreset(val)),
            displayValues: {
              'saudi': 'preset_saudi'.tr(),
              'egypt': 'preset_egypt'.tr(),
            },
          ),
        if (state.iqamaSystem == 'manual')
          ...state.iqamaDelays.entries.map(
            (e) => _buildNumberInputTile(
              context,
              e.key.tr(),
              'minutes'.tr(),
              e.value,
              (val) => context.read<SettingsScreenBloc>().add(
                UpdateIqamaDelay(e.key, val),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAudioSection(BuildContext context, SettingsScreenLoaded state) {
    return SakinaSettingsSection(
      header: Text('audio_settings'.tr().toUpperCase()),
      children: [
        _buildAudioTile(
          context,
          'fajr_adhan'.tr(),
          state.fajrAdhanSound,
          (s) => context.read<SettingsScreenBloc>().add(
            UpdateAdhanSound(isFajr: true, sound: s),
          ),
        ),
        _buildAudioTile(
          context,
          'other_adhan'.tr(),
          state.otherAdhanSound,
          (s) => context.read<SettingsScreenBloc>().add(
            UpdateAdhanSound(isFajr: false, sound: s),
          ),
        ),
        _buildAudioTile(
          context,
          'fajr_iqama'.tr(),
          state.fajrIqamaSound,
          (s) => context.read<SettingsScreenBloc>().add(
            UpdateIqamaSound(isFajr: true, sound: s),
          ),
        ),
        _buildAudioTile(
          context,
          'other_iqama'.tr(),
          state.otherIqamaSound,
          (s) => context.read<SettingsScreenBloc>().add(
            UpdateIqamaSound(isFajr: false, sound: s),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminSection(BuildContext context, SettingsScreenLoaded state) {
    return SakinaSettingsSection(
      header: Text('admin'.tr().toUpperCase()),
      children: [
        SakinaSettingsTile(
          leading: const Icon(
            CupertinoIcons.cloud_download,
            color: CupertinoColors.activeBlue,
          ),
          title: Text('check_for_updates'.tr()),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UpdateScreen()),
            );
          },
        ),
        SakinaSettingsTile(
          leading: const Icon(
            CupertinoIcons.trash,
            color: CupertinoColors.destructiveRed,
          ),
          title: Text(
            'reset_all_data'.tr(),
            style: const TextStyle(color: CupertinoColors.destructiveRed),
          ),
          onTap: () => _showResetConfirmation(context),
        ),
      ],
    );
  }

  Widget _buildTestSection(BuildContext context) {
    return SakinaSettingsSection(
      header: const Text('DEVELOPER TESTING'),
      children: [
        SakinaSettingsTile(
          leading: const Icon(CupertinoIcons.bell, color: Color(0xFFD4AF37)),
          title: const Text('Test Adhan (10s)'),
          onTap: () async {
            await TestService.triggerAdhanNow();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Adhan scheduled in 10s')),
            );
          },
        ),
        SakinaSettingsTile(
          leading: const Icon(
            CupertinoIcons.time,
            color: CupertinoColors.activeBlue,
          ),
          title: const Text('Test Iqama (15s)'),
          onTap: () async {
            await TestService.triggerIqamaNow();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Iqama scheduled in 15s')),
            );
          },
        ),
        SakinaSettingsTile(
          leading: const Icon(
            CupertinoIcons.infinite,
            color: CupertinoColors.activeGreen,
          ),
          title: const Text('Test Dhikr Alarm (12s)'),
          onTap: () async {
            await TestService.triggerDhikrNow();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dhikr alarm scheduled in 12s')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return SakinaSettingsSection(
      footer: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.data?.version ?? '';
                return Text(
                  'app_version'.tr(namedArgs: {'version': version}),
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 13,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'app_desc'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      children: [
        SakinaSettingsTile(
          title: Text('about_app'.tr()),
          trailing: const Icon(Icons.chevron_right, size: 14),
          onTap: () => _launchURL(context, 'https://tawabti.app/about'),
        ),
        SakinaSettingsTile(
          title: Text('privacy_policy'.tr()),
          trailing: const Icon(Icons.chevron_right, size: 14),
          onTap: () => _launchURL(context, 'https://tawabti.app/privacy'),
        ),
        SakinaSettingsTile(
          title: Text('terms_of_service'.tr()),
          trailing: const Icon(Icons.chevron_right, size: 14),
          onTap: () => _launchURL(context, 'https://tawabti.app/terms'),
        ),
      ],
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }

    // Never fail silently — a dead policy link looks like a broken app to
    // users (and to Play reviewers tapping the privacy policy entry).
    if (!launched && context.mounted) {
      showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text('error_occurred'.tr()),
          content: Text('couldnt_open_page'.tr()),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx),
              child: Text('ok'.tr()),
            ),
          ],
        ),
      );
    }
  }

  void _showResetConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('reset_all_data'.tr()),
        content: Text('reset_confirmation_msg'.tr()),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr()),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              context.read<SettingsScreenBloc>().add(ResetAllData());
              Navigator.pop(ctx);
            },
            child: Text('reset'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const CupertinoActivityIndicator();
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
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: context.primaryColor,
      ),
    );
  }

  Widget _buildDropdownTile(
    BuildContext context,
    String title,
    String currentValue,
    List<String> options,
    void Function(String) onChanged, {
    Map<String, String>? displayValues,
    bool translateOptions = true,
  }) {
    final infoText =
        displayValues?[currentValue] ??
        (translateOptions ? currentValue.tr() : currentValue);

    return SakinaSettingsTile(
      title: Text(title),
      additionalInfo: Text(infoText),
      trailing: const Icon(Icons.chevron_right, size: 14),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey3.resolveFrom(context),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  // Options
                  ...options.map((option) {
                    final isSelected = currentValue == option;
                    final label =
                        displayValues?[option] ??
                        (translateOptions ? option.tr() : option);
                    return SakinaSettingsTile(
                      title: Text(
                        label,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? context.primaryColor
                              : CupertinoColors.label.resolveFrom(context),
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              CupertinoIcons.checkmark_alt_circle_fill,
                              color: context.primaryColor,
                              size: 24,
                            )
                          : null,
                      onTap: () {
                        onChanged(option);
                        Navigator.pop(ctx);
                      },
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNumberInputTile(
    BuildContext context,
    String title,
    String subtitle,
    int currentValue,
    Function(int) onChanged,
  ) {
    return SakinaSettingsTile(
      title: Text(title),
      additionalInfo: Text('$currentValue $subtitle'),
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Container(
            height: 300,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey3.resolveFrom(context),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  // Title + Done button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label.resolveFrom(context),
                          ),
                        ),
                        CupertinoButton(
                          child: Text('done'.tr()),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: currentValue - 1,
                      ),
                      itemExtent: 32,
                      onSelectedItemChanged: (index) {
                        onChanged(index + 1);
                      },
                      children: List.generate(
                        60,
                        (i) => Center(child: Text('${i + 1}')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudioTile(
    BuildContext context,
    String title,
    String currentSound,
    Function(String) onSelect,
  ) {
    final options = ['zanfajr.mp3', 'azan8.mp3', 'MakkahIQamah.mp3'];
    return _buildDropdownTile(
      context,
      title,
      currentSound,
      options,
      onSelect,
      translateOptions: false,
    );
  }
}
