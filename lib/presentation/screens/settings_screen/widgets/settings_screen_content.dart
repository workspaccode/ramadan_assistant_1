import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hijri/hijri_calendar.dart';
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
        return Scaffold(
          // backgroundColor: context.backgroundColor,
          body: Container(
            decoration: BoxDecoration(
              gradient: isRamadan
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF2E7D32).withOpacity(0.02),
                        const Color(0xFF4CAF50).withOpacity(0.01),
                      ],
                    )
                  : null,
            ),
            child: CustomScrollView(
              slivers: [
                _buildRamadanAppBar(context, isRamadan),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (state is SettingsScreenLoaded) ...[
                        _buildRamadanCard(context, isRamadan),
                        const SizedBox(height: 20),
                        _buildLocationSection(context, state),
                        const SizedBox(height: 20),
                        _buildAppearanceSection(context, state),
                        const SizedBox(height: 20),
                        _buildPrayerSection(context, state),
                        const SizedBox(height: 20),
                        _buildIqamaSection(context, state),
                        const SizedBox(height: 20),
                        _buildAudioSection(context, state),
                        const SizedBox(height: 20),
                        _buildAdminSection(context, state),
                        const SizedBox(height: 20),
                        _buildFooter(context),
                        const SizedBox(height: 40),
                      ] else
                        _buildLoadingState(),
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
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: isRamadan
          ? const Color(0xFF2E7D32)
          : const Color(0xFF1976D2),
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRamadan) ...[
              SvgPicture.asset(
                'assets/image/ramadan_star.svg',
                width: 24,
                height: 24,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              'settings_title'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isRamadan) ...[
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/image/ramadan_star.svg',
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ],
          ],
        ),
        titlePadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isRamadan
                  ? [const Color(0xFF2E7D32), const Color(0xFF4CAF50)]
                  : [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: isRamadan
              ? Center(
                  child: Opacity(
                    opacity: 0.1,
                    child: SvgPicture.asset(
                      'assets/image/islamic_pattern.svg',
                      width: 200,
                      height: 200,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildRamadanCard(BuildContext context, bool isRamadan) {
    if (!isRamadan) {
      return const SizedBox.shrink();
    }

    return Container(
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
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
      ),
    );
  }

  Widget _buildLocationSection(
    BuildContext context,
    SettingsScreenLoaded state,
  ) {
    return _buildSection(context, 'location'.tr(), Icons.location_on, [
      ListTile(
        title: Text('current_location'.tr()),
        subtitle: Text(
          '${state.city ?? 'unknown'.tr()}, ${state.country ?? ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () =>
              context.read<SettingsScreenBloc>().add(RefreshLocation()),
        ),
      ),
    ]);
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    SettingsScreenLoaded state,
  ) {
    return _buildSection(context, 'appearance'.tr(), Icons.palette, [
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
      const Divider(),
      _buildLanguageTile(context),
      const Divider(),
      _buildColorPaletteTile(context, state),
      const Divider(),
      _buildFontSizeSlider(context, state),
    ]);
  }

  Widget _buildColorPaletteTile(
    BuildContext context,
    SettingsScreenLoaded state,
  ) {
    return _buildDropdownTile(
      context,
      'color_palette'.tr(),
      '',
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

        return ListTile(
          title: Text('language'.tr()),
          trailing: DropdownButton<String>(
            value: langCode,
            onChanged: (val) {
              if (val != null) {
                context.read<LanguageBloc>().add(UpdateLanguage(val));
              }
            },
            items: const [
              DropdownMenuItem(value: 'ar', child: Text('العربية')),
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ur', child: Text('اردو')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFontSizeSlider(
    BuildContext context,
    SettingsScreenLoaded state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'font_size'.tr(),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Slider(
          value: state.fontSizeMultiplier,
          min: 0.8,
          max: 1.4,
          divisions: 6,
          label: '${(state.fontSizeMultiplier * 100).toInt()}%',
          onChanged: (val) {
            context.read<SettingsScreenBloc>().add(UpdateFontSize(val));
            context.read<ThemeBloc>().add(UpdateFontSizeMultiplier(val));
          },
        ),
      ],
    );
  }

  Widget _buildPrayerSection(BuildContext context, SettingsScreenLoaded state) {
    return _buildSection(context, 'prayer_settings'.tr(), Icons.access_time, [
      _buildDropdownTile(
        context,
        'calculation_method'.tr(),
        '',
        state.calculationMethod,
        ['muslimWorldLeague', 'ummAlQura', 'egyptian', 'karachi'],
        (val) => context.read<SettingsScreenBloc>().add(
          UpdateCalculationMethod(val),
        ),
      ),
      const Divider(),
      _buildDropdownTile(
        context,
        'madhab'.tr(),
        '',
        state.madhab,
        ['shafi', 'hanafi'],
        (val) => context.read<SettingsScreenBloc>().add(UpdateMadhab(val)),
      ),
    ]);
  }

  Widget _buildIqamaSection(BuildContext context, SettingsScreenLoaded state) {
    return _buildSection(
      context,
      'iqama_settings'.tr(),
      Icons.notifications_active,
      [
        _buildDropdownTile(
          context,
          'system'.tr(),
          '',
          state.iqamaSystem,
          ['manual', 'preset'],
          (val) =>
              context.read<SettingsScreenBloc>().add(UpdateIqamaSystem(val)),
        ),
        if (state.iqamaSystem == 'preset') ...[
          const Divider(),
          _buildDropdownTile(
            context,
            'preset'.tr(),
            '',
            state.iqamaPreset,
            ['saudi', 'egypt'],
            (val) =>
                context.read<SettingsScreenBloc>().add(UpdateIqamaPreset(val)),
          ),
        ],
        if (state.iqamaSystem == 'manual') ...[
          const Divider(),
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
      ],
    );
  }

  Widget _buildAudioSection(BuildContext context, SettingsScreenLoaded state) {
    return _buildSection(context, 'audio_settings'.tr(), Icons.volume_up, [
      _buildAudioHeader('adhan'.tr()),
      _buildAudioTile(
        context,
        'fajr'.tr(),
        state.fajrAdhanSound,
        (s) => context.read<SettingsScreenBloc>().add(
          UpdateAdhanSound(isFajr: true, sound: s),
        ),
      ),
      _buildAudioTile(
        context,
        'other_prayers'.tr(),
        state.otherAdhanSound,
        (s) => context.read<SettingsScreenBloc>().add(
          UpdateAdhanSound(isFajr: false, sound: s),
        ),
      ),
      const Divider(),
      _buildAudioHeader('iqama'.tr()),
      _buildAudioTile(
        context,
        'fajr'.tr(),
        state.fajrIqamaSound,
        (s) => context.read<SettingsScreenBloc>().add(
          UpdateIqamaSound(isFajr: true, sound: s),
        ),
      ),
      _buildAudioTile(
        context,
        'other_prayers'.tr(),
        state.otherIqamaSound,
        (s) => context.read<SettingsScreenBloc>().add(
          UpdateIqamaSound(isFajr: false, sound: s),
        ),
      ),
    ]);
  }

  Widget _buildAudioHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildAudioTile(
    BuildContext context,
    String title,
    String currentSound,
    Function(String) onSelect,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(currentSound),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Show a simple dialog with sound options
        showDialog(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: Text('select_sound'.tr()),
            children: ['zanfajr.mp3', 'azan8.mp3', 'MakkahIQamah.mp3']
                .map(
                  (s) => SimpleDialogOption(
                    child: Text(s),
                    onPressed: () {
                      onSelect(s);
                      Navigator.pop(ctx);
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildAdminSection(BuildContext context, SettingsScreenLoaded state) {
    return _buildSection(context, 'admin'.tr(), Icons.admin_panel_settings, [
      ListTile(
        leading: const Icon(Icons.system_update),
        title: Text('check_for_updates'.tr()),
        onTap: () {
          context.read<SettingsScreenBloc>().add(CheckForUpdates());
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('checking_updates'.tr())));
        },
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.delete_forever, color: Colors.red),
        title: Text(
          'reset_all_data'.tr(),
          style: const TextStyle(color: Colors.red),
        ),
        onTap: () => _showResetConfirmation(context),
      ),
    ]);
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('about_app'.tr()),
          onTap: () => _launchURL('https://example.com/about'),
        ),
        ListTile(
          title: Text('privacy_policy'.tr()),
          onTap: () => _launchURL('https://example.com/privacy'),
        ),
        ListTile(
          title: Text('terms_of_service'.tr()),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('reset_all_data'.tr()),
        content: Text('reset_confirmation_msg'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsScreenBloc>().add(ResetAllData());
              Navigator.pop(ctx);
            },
            child: Text(
              'reset'.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownTile(
    BuildContext context,
    String title,
    String subtitle,
    String currentValue,
    List<String> options,
    void Function(String) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: DropdownButton<String>(
        value: currentValue,
        onChanged: (val) => val != null ? onChanged(val) : null,
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o.tr())))
            .toList(),
      ),
    );
  }

  Widget _buildNumberInputTile(
    BuildContext context,
    String title,
    String subtitle,
    int currentValue,
    Function(int) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: SizedBox(
        width: 40,
        child: TextField(
          decoration: const InputDecoration(isDense: true),
          keyboardType: TextInputType.number,
          controller: TextEditingController(text: currentValue.toString()),
          onSubmitted: (v) {
            final i = int.tryParse(v);
            if (i != null) onChanged(i);
          },
        ),
      ),
    );
  }
}
