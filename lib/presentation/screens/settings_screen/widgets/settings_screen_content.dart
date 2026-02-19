import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/blocs/language_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/language_event.dart';
import 'package:ramadan_assistant/presentation/blocs/language_state.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_event.dart';
import 'package:ramadan_assistant/presentation/blocs/theme_state.dart';
import 'package:ramadan_assistant/presentation/screens/settings_screen/bloc/settings_screen_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreenContent extends StatelessWidget {
  const SettingsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final today = HijriCalendar.now();
    final isRamadan = today.hMonth == 9;

    return BlocBuilder<SettingsScreenBloc, SettingsScreenState>(
      builder: (context, state) {
        final backgroundColor = context.isDark
            ? const Color(0xFF000000)
            : const Color(0xFFF2F2F7);

        return CupertinoPageScaffold(
          backgroundColor: backgroundColor,
          child: Container(
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
                SliverSafeArea(
                  top: false,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (state is SettingsScreenLoaded) ...[
                        _buildRamadanCard(context, isRamadan),
                        _buildLocationSection(context, state),
                        _buildAppearanceSection(context, state),
                        _buildPrayerSection(context, state),
                        _buildIqamaSection(context, state),
                        _buildAudioSection(context, state),
                        _buildAdminSection(context, state),
                        _buildFooter(context),
                        const SizedBox(height: 40),
                      ] else
                        SliverFillRemaining(
                          child: Center(child: _buildLoadingState()),
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRamadanAppBar(BuildContext context, bool isRamadan) {
    final titleText = 'settings_title'.tr();

    return CupertinoSliverNavigationBar(
      largeTitle: Text(
        titleText,
        style: TextStyle(
          color: context.isDark ? CupertinoColors.white : CupertinoColors.black,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor:
          (isRamadan ? const Color(0xFF2E7D32) : context.primaryColor)
              .withValues(alpha: 0.8),
      border: null,
      middle: isRamadan
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/image/ramadan_star.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  titleText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            )
          : null,
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        child: const Icon(CupertinoIcons.refresh, color: Colors.white),
        onPressed: () {
          context.read<SettingsScreenBloc>().add(LoadSettings());
        },
      ),
    );
  }

  Widget _buildRamadanCard(BuildContext context, bool isRamadan) {
    if (!isRamadan) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF2E7D32), const Color(0xFF4CAF50)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.nights_stay, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'إعدادات رمضان',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.nights_stay, color: Colors.white, size: 28),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'شهر القرآن والرحمة والمغفرة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'َنَصْبٌ فِي خَدِ الْعَدَالَةِ شَهْرُ رَمَضَانَ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(
    BuildContext context,
    SettingsScreenLoaded state,
  ) {
    return CupertinoListSection.insetGrouped(
      header: Text('location'.tr().toUpperCase()),
      children: [
        CupertinoListTile(
          title: Text('current_location'.tr()),
          subtitle: Text(
            '${state.city ?? 'unknown'.tr()}, ${state.country ?? ''}',
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.location_north_fill, size: 20),
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
    return CupertinoListSection.insetGrouped(
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
    return _buildDropdownTile(
      context,
      'color_palette'.tr(),
      state.colorPaletteId ?? 'default',
      ['default', 'midnight', 'desert'],
      (val) {
        context.read<SettingsScreenBloc>().add(UpdateSettingsColorPalette(val));
        context.read<ThemeBloc>().add(UpdateColorPalette(val));
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String langCode = 'ar';
        if (state is LanguageLoaded) langCode = state.languageCode;

        final langNames = {'ar': 'العربية', 'en': 'English', 'ur': 'اردو'};

        return _buildDropdownTile(
          context,
          'language'.tr(),
          langNames[langCode] ?? langCode,
          ['ar', 'en', 'ur'],
          (val) {
            context.read<LanguageBloc>().add(UpdateLanguage(val));
          },
          displayValues: langNames,
        );
      },
    );
  }

  Widget _buildFontSizeSlider(
    BuildContext context,
    SettingsScreenLoaded state,
  ) {
    return CupertinoListTile(
      title: Text('font_size'.tr()),
      additionalInfo: Text('${(state.fontSizeMultiplier * 100).toInt()}%'),
      subtitle: SizedBox(
        width: double.infinity,
        child: CupertinoSlider(
          value: state.fontSizeMultiplier,
          min: 0.8,
          max: 1.4,
          divisions: 6,
          onChanged: (val) {
            context.read<SettingsScreenBloc>().add(UpdateFontSize(val));
            context.read<ThemeBloc>().add(UpdateFontSizeMultiplier(val));
          },
        ),
      ),
    );
  }

  Widget _buildPrayerSection(BuildContext context, SettingsScreenLoaded state) {
    return CupertinoListSection.insetGrouped(
      header: Text('prayer_settings'.tr().toUpperCase()),
      children: [
        _buildDropdownTile(
          context,
          'calculation_method'.tr(),
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
        ),
      ],
    );
  }

  Widget _buildIqamaSection(BuildContext context, SettingsScreenLoaded state) {
    return CupertinoListSection.insetGrouped(
      header: Text('iqama_settings'.tr().toUpperCase()),
      children: [
        _buildDropdownTile(
          context,
          'system'.tr(),
          state.iqamaSystem,
          ['manual', 'preset'],
          (val) =>
              context.read<SettingsScreenBloc>().add(UpdateIqamaSystem(val)),
        ),
        if (state.iqamaSystem == 'preset')
          _buildDropdownTile(
            context,
            'preset'.tr(),
            state.iqamaPreset,
            ['saudi', 'egypt'],
            (val) =>
                context.read<SettingsScreenBloc>().add(UpdateIqamaPreset(val)),
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
    return CupertinoListSection.insetGrouped(
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
    return CupertinoListSection.insetGrouped(
      header: Text('admin'.tr().toUpperCase()),
      children: [
        CupertinoListTile(
          leading: const Icon(
            CupertinoIcons.cloud_download,
            color: CupertinoColors.activeBlue,
          ),
          title: Text('check_for_updates'.tr()),
          onTap: () {
            context.read<SettingsScreenBloc>().add(CheckForUpdates());
          },
        ),
        CupertinoListTile(
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

  Widget _buildFooter(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          title: Text('about_app'.tr()),
          trailing: const Icon(CupertinoIcons.chevron_right, size: 14),
          onTap: () => _launchURL('https://example.com/about'),
        ),
        CupertinoListTile(
          title: Text('privacy_policy'.tr()),
          trailing: const Icon(CupertinoIcons.chevron_right, size: 14),
          onTap: () => _launchURL('https://example.com/privacy'),
        ),
        CupertinoListTile(
          title: Text('terms_of_service'.tr()),
          trailing: const Icon(CupertinoIcons.chevron_right, size: 14),
          onTap: () => _launchURL('https://example.com/terms'),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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
    return CupertinoListTile(
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
  }) {
    return CupertinoListTile(
      title: Text(title),
      additionalInfo: Text(displayValues?[currentValue] ?? currentValue.tr()),
      trailing: const Icon(CupertinoIcons.chevron_up_chevron_down, size: 14),
      onTap: () {
        final initialIndex = options.indexOf(currentValue);
        showCupertinoModalPopup(
          context: context,
          builder: (ctx) => Container(
            height: 250,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CupertinoButton(
                          child: Text('done'.tr()),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: initialIndex != -1 ? initialIndex : 0,
                      ),
                      itemExtent: 32,
                      onSelectedItemChanged: (index) {
                        onChanged(options[index]);
                      },
                      children: options
                          .map(
                            (o) => Center(
                              child: Text(displayValues?[o] ?? o.tr()),
                            ),
                          )
                          .toList(),
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

  Widget _buildNumberInputTile(
    BuildContext context,
    String title,
    String subtitle,
    int currentValue,
    Function(int) onChanged,
  ) {
    return CupertinoListTile(
      title: Text(title),
      additionalInfo: Text('$currentValue $subtitle'),
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (ctx) => Container(
            height: 250,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CupertinoButton(
                          child: Text('done'.tr()),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
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
    return _buildDropdownTile(context, title, currentSound, options, onSelect);
  }
}
