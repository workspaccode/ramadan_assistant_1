import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/theme/ramadan_theme_extension.dart';

extension ContextExtensions on BuildContext {
  // Theme
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;
  RamadanThemeExtension get ramadanTheme =>
      theme.extension<RamadanThemeExtension>()!;

  // Typography
  TextStyle? get displayLarge => textTheme.displayLarge;
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  TextStyle? get titleLarge => textTheme.titleLarge;
  TextStyle? get bodyLarge => textTheme.bodyLarge;
  TextStyle? get bodyMedium => textTheme.bodyMedium;

  // Colors
  Color get primaryColor => colorScheme.primary;
  Color get onPrimaryColor => colorScheme.onPrimary;
  Color get secondaryColor => colorScheme.secondary;
  Color get onSecondaryColor => colorScheme.onSecondary;
  Color get backgroundColor => theme.scaffoldBackgroundColor;
  Color get onBackgroundColor => colorScheme.onSurface;
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get cardColor => theme.cardColor;
  Color get errorColor => colorScheme.error;

  // Localization
  AppLocalizations get loc => AppLocalizations.of(this)!;
  Locale get locale => Localizations.localeOf(this);

  bool get isRtl => Directionality.of(this) == ui.TextDirection.rtl;

  // Dimensions
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  // Navigation
  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  Future<T?> push<T extends Object?>(Route<T> route) =>
      Navigator.of(this).push(route);

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) => Navigator.of(this).pushNamed(routeName, arguments: arguments);

  // Safe Area
  double get paddingTop => MediaQuery.paddingOf(this).top;
  double get paddingBottom => MediaQuery.paddingOf(this).bottom;
}

extension StringTranslateExtension on String {
  String tr({List<String>? args, Map<String, String>? namedArgs}) {
    return AppLocalizationsLookup.translate(
      this,
      args: args,
      namedArgs: namedArgs,
    );
  }
}

class AppLocalizationsLookup {
  static AppLocalizations? _instance;
  static AppLocalizations get instance {
    if (_instance == null) {
      throw StateError(
        'AppLocalizationsLookup has not been initialized. Call AppLocalizationsLookup.init(context) first.',
      );
    }
    return _instance!;
  }

  static void init(BuildContext context) {
    _instance = AppLocalizations.of(context);
  }

  static String translate(
    String key, {
    List<String>? args,
    Map<String, String>? namedArgs,
  }) {
    switch (key) {
      case 'now':
        return instance.now;
      case 'passed':
        return instance.passed;
      case 'upcoming':
        return instance.upcoming;
      case 'today':
        return instance.today;
      case 'change':
        return instance.change;
      case 'cancel':
        return instance.cancel;
      case 'close':
        return instance.close;
      case 'retry':
        return instance.retry;
      case 'got_it_continue':
        return instance.got_it_continue;
      case 'skip_for_now':
        return instance.skip_for_now;
      case 'coming_soon':
        return instance.coming_soon;
      case 'minutes':
        return instance.minutes;
      case 'min':
        return instance.min;
      case 'hour':
        return instance.hour;
      case 'times':
        return instance.times;
      case 'location':
        return instance.location;
      case 'appearance':
        return instance.appearance;
      case 'completed':
        return instance.completed;
      case 'ongoing':
        return instance.ongoing;
      case 'waiting':
        return instance.waiting;
      case 'step_tawaf':
        return instance.step_tawaf;
      case 'version':
        return instance.version;
      case 'something_went_wrong':
        return instance.something_went_wrong;
      case 'error_prefix':
        return instance.error_prefix(args?[0] ?? '');
      case 'tab_prayers':
        return instance.tab_prayers;
      case 'tab_tasbih':
        return instance.tab_tasbih;
      case 'tab_adhkar':
        return instance.tab_adhkar;
      case 'features':
        return instance.features;
      case 'daily_progress':
        return instance.daily_progress;
      case 'days_streak':
        return instance.days_streak;
      case 'pages_read':
        return instance.pages_read;
      case 'tasbih_total':
        return instance.tasbih_total;
      case 'eid_al_fitr_title':
        return instance.eid_al_fitr_title;
      case 'eid_al_fitr_message':
        return instance.eid_al_fitr_message;
      case 'eid_al_adha_title':
        return instance.eid_al_adha_title;
      case 'eid_al_adha_message':
        return instance.eid_al_adha_message;
      case 'hijri_new_year_title':
        return instance.hijri_new_year_title;
      case 'hijri_new_year_message':
        return instance.hijri_new_year_message;
      case 'visit_site':
        return instance.visit_site;
      case 'daily_hadith':
        return instance.daily_hadith;
      case 'prayer_times_title':
        return instance.prayer_times_title;
      case 'next_prayer':
        return instance.next_prayer;
      case 'time_remaining':
        return instance.time_remaining;
      case 'fajr':
        return instance.fajr;
      case 'sunrise':
        return instance.sunrise;
      case 'dhuhr':
        return instance.dhuhr;
      case 'asr':
        return instance.asr;
      case 'maghrib':
        return instance.maghrib;
      case 'isha':
        return instance.isha;
      case 'duha':
        return instance.duha;
      case 'witr':
        return instance.witr;
      case 'rakats':
        return instance.rakats;
      case 'sunnah':
        return instance.sunnah;
      case 'sunnah_status':
        return instance.sunnah_status;
      case 'sunnah_prayer':
        return instance.sunnah_prayer;
      case 'fard_prayer':
        return instance.fard_prayer;
      case 'preferred_duas':
        return instance.preferred_duas;
      case 'before_prayer':
        return instance.before_prayer;
      case 'after_prayer':
        return instance.after_prayer;
      case 'method':
        return instance.method;
      case 'madhab':
        return instance.madhab;
      case 'muslimWorldLeague':
        return instance.muslimWorldLeague;
      case 'ummAlQura':
        return instance.ummAlQura;
      case 'egyptian':
        return instance.egyptian;
      case 'karachi':
        return instance.karachi;
      case 'dubai':
        return instance.dubai;
      case 'qatar':
        return instance.qatar;
      case 'kuwait':
        return instance.kuwait;
      case 'singapore':
        return instance.singapore;
      case 'northAmerica':
        return instance.northAmerica;
      case 'method_muslimWorldLeague':
        return instance.method_muslimWorldLeague;
      case 'method_egyptian':
        return instance.method_egyptian;
      case 'method_karachi':
        return instance.method_karachi;
      case 'method_ummAlQura':
        return instance.method_ummAlQura;
      case 'method_dubai':
        return instance.method_dubai;
      case 'method_qatar':
        return instance.method_qatar;
      case 'method_kuwait':
        return instance.method_kuwait;
      case 'method_singapore':
        return instance.method_singapore;
      case 'method_northAmerica':
        return instance.method_northAmerica;
      case 'madhab_shafi':
        return instance.madhab_shafi;
      case 'madhab_hanafi':
        return instance.madhab_hanafi;
      case 'qibla_title':
        return instance.qibla_title;
      case 'getting_qibla_direction':
        return instance.getting_qibla_direction;
      case 'location_error':
        return instance.location_error;
      case 'location_refresh':
        return instance.location_refresh;
      case 'location_required_msg':
        return instance.location_required_msg;
      case 'ar_mode':
        return instance.ar_mode;
      case 'ar_not_supported':
        return instance.ar_not_supported;
      case 'ar_instruction':
        return instance.ar_instruction;
      case 'show_compass':
        return instance.show_compass;
      case 'show_map':
        return instance.show_map;
      case 'location_error_title':
        return instance.location_error_title;
      case 'open_location_settings':
        return instance.open_location_settings;
      case 'checking_location':
        return instance.checking_location;
      case 'location_denied':
        return instance.location_denied;
      case 'location_permanently_denied':
        return instance.location_permanently_denied;
      case 'calibrating_compass':
        return instance.calibrating_compass;
      case 'current_heading':
        return instance.current_heading;
      case 'north':
        return instance.north;
      case 'east':
        return instance.east;
      case 'south':
        return instance.south;
      case 'west':
        return instance.west;
      case 'qibla':
        return instance.qibla;
      case 'tasbih':
        return instance.tasbih;
      case 'prayer_times':
        return instance.prayer_times;
      case 'tasbih_title':
        return instance.tasbih_title;
      case 'target':
        return instance.target;
      case 'reset':
        return instance.reset;
      case 'reset_message':
        return instance.reset_message;
      case 'start_tasbih':
        return instance.start_tasbih;
      case 'select_target':
        return instance.select_target;
      case 'progress':
        return instance.progress;
      case 'tap_to_count_hint':
        return instance.tap_to_count_hint;
      case 'wird_title':
        return instance.wird_title;
      case 'wird_plan_selection':
        return instance.wird_plan_selection;
      case 'wird_khatma_plan':
        return instance.wird_khatma_plan;
      case 'wird_pages_prayer_plan':
        return instance.wird_pages_prayer_plan;
      case 'wird_juz_plan':
        return instance.wird_juz_plan;
      case 'wird_khatmas':
        return instance.wird_khatmas(args?[0] ?? '');
      case 'wird_pages_per_prayer':
        return instance.wird_pages_per_prayer(args?[0] ?? '');
      case 'wird_juz_per_day':
        return instance.wird_juz_per_day(args?[0] ?? '');
      case 'wird_daily_target':
        return instance.wird_daily_target(args?[0] ?? '');
      case 'wird_total_progress':
        return instance.wird_total_progress;
      case 'wird_page_of':
        return instance.wird_page_of(args?[0] ?? '', args?[1] ?? '');
      case 'wird_log_progress':
        return instance.wird_log_progress;
      case 'wird_pages_read':
        return instance.wird_pages_read;
      case 'wird_start_plan':
        return instance.wird_start_plan;
      case 'wird_change_plan':
        return instance.wird_change_plan;
      case 'wird_last_read_page':
        return instance.wird_last_read_page;
      case 'wird_continue_reading':
        return instance.wird_continue_reading;
      case 'wird_daily_log':
        return instance.wird_daily_log;
      case 'wird_prayer_target':
        return instance.wird_prayer_target(args?[0] ?? '');
      case 'wird_add_pages':
        return instance.wird_add_pages;
      case 'wird_tracker':
        return instance.wird_tracker;
      case 'wird_history':
        return instance.wird_history;
      case 'wird_streak':
        return instance.wird_streak;
      case 'wird_total_pages':
        return instance.wird_total_pages;
      case 'wird_weekly_activity':
        return instance.wird_weekly_activity;
      case 'settings_title':
        return instance.settings_title;
      case 'settings':
        return instance.settings;
      case 'language':
        return instance.language;
      case 'theme':
        return instance.theme;
      case 'dark_mode':
        return instance.dark_mode;
      case 'light_mode':
        return instance.light_mode;
      case 'enable_dark_theme':
        return instance.enable_dark_theme;
      case 'color_palette':
        return instance.color_palette;
      case 'default':
      case 'defaultLabel':
        return instance.defaultLabel;
      case 'emerald':
        return instance.emerald;
      case 'midnight':
        return instance.midnight;
      case 'desert':
        return instance.desert;
      case 'ocean':
        return instance.ocean;
      case 'font_size':
        return instance.font_size;
      case 'font_size_preview':
        return instance.font_size_preview;
      case 'current_location':
        return instance.current_location;
      case 'unknown':
        return instance.unknown;
      case 'app_icon':
        return instance.app_icon;
      case 'select_icon':
        return instance.select_icon;
      case 'Standard':
      case 'Ramadan Classic':
      case 'ramadanClassic':
        return instance.ramadanClassic;
      case 'notifications':
        return instance.notifications;
      case 'global_notifications':
        return instance.global_notifications;
      case 'enable_all_notifications':
        return instance.enable_all_notifications;
      case 'hijri_calendar':
        return instance.hijri_calendar;
      case 'hijri_adjustment':
        return instance.hijri_adjustment;
      case 'day_adjustment':
        return instance.day_adjustment(args?[0] ?? '');
      case 'adhan':
        return instance.adhan;
      case 'iqama':
        return instance.iqama;
      case 'other_prayers':
        return instance.other_prayers;
      case 'ramadan_kareem':
        return instance.ramadan_kareem;
      case 'tap_for_blessing':
        return instance.tap_for_blessing;
      case 'app_name':
        return instance.app_name;
      case 'app_desc':
        return instance.app_desc;
      case 'app_version':
        return instance.app_version(namedArgs?['version'] ?? '');
      case 'admin':
        return instance.admin;
      case 'check_for_updates':
        return instance.check_for_updates;
      case 'checking_updates':
        return instance.checking_updates;
      case 'reset_all_data':
        return instance.reset_all_data;
      case 'reset_confirmation_msg':
        return instance.reset_confirmation_msg;
      case 'about':
        return instance.about;
      case 'about_app':
        return instance.about_app;
      case 'privacy_policy':
        return instance.privacy_policy;
      case 'terms_of_service':
        return instance.terms_of_service;
      case 'next':
        return instance.next;
      case 'fajr_dua_1':
        return instance.fajr_dua_1;
      case 'fajr_dua_2':
        return instance.fajr_dua_2;
      case 'dhuhr_dua_1':
        return instance.dhuhr_dua_1;
      case 'dhuhr_dua_2':
        return instance.dhuhr_dua_2;
      case 'asr_dua_1':
        return instance.asr_dua_1;
      case 'asr_dua_2':
        return instance.asr_dua_2;
      case 'maghrib_dua_1':
        return instance.maghrib_dua_1;
      case 'maghrib_dua_2':
        return instance.maghrib_dua_2;
      case 'isha_dua_1':
        return instance.isha_dua_1;
      case 'isha_dua_2':
        return instance.isha_dua_2;
      case 'prayer_time':
        return instance.prayer_time;
      case 'fard':
        return instance.fard;
      case 'hours':
        return instance.hours;
      case 'SubhanAllah':
      case 'subhanAllah':
        return instance.subhanAllah;
      case 'tap_to_count':
        return instance.tap_to_count;
      case 'dhikr_list':
        return instance.dhikr_list;
      case 'reward_astaghfirullah':
        return instance.reward_astaghfirullah;
      case 'salawat':
        return instance.salawat;
      case 'reward_salawat':
        return instance.reward_salawat;
      case 'subhanallah_wabihamdihi':
        return instance.subhanallah_wabihamdihi;
      case 'reward_wabihamdihi':
        return instance.reward_wabihamdihi;
      case 'lahawla':
        return instance.lahawla;
      case 'reward_lahawla':
        return instance.reward_lahawla;
      case 'custom_target':
        return instance.custom_target;
      case 'select_dhikr':
        return instance.select_dhikr;
      case 'reward_subhanallah':
        return instance.reward_subhanallah;
      case 'Alhamdulillah':
      case 'alhamdulillah':
        return instance.alhamdulillah;
      case 'reward_alhamdulillah':
        return instance.reward_alhamdulillah;
      case 'Allahu Akbar':
      case 'allahuAkbar':
        return instance.allahuAkbar;
      case 'reward_allahuakbar':
        return instance.reward_allahuakbar;
      case 'La ilaha illallah':
      case 'laIlahaIllallah':
        return instance.laIlahaIllallah;
      case 'reward_lailahaillallah':
        return instance.reward_lailahaillallah;
      case 'Astaghfirullah':
      case 'astaghfirullah':
        return instance.astaghfirullah;
      case 'wird_log_past_day':
        return instance.wird_log_past_day;
      case 'other':
        return instance.other;
      case 'wird_error_loading_history':
        return instance.wird_error_loading_history;
      case 'wird_avg_per_day':
        return instance.wird_avg_per_day;
      case 'wird_details_for':
        return instance.wird_details_for;
      case 'wird_no_data_day':
        return instance.wird_no_data_day;
      case 'duha_dua_1':
        return instance.duha_dua_1;
      case 'duha_dua_2':
        return instance.duha_dua_2;
      case 'minimum':
        return instance.minimum;
      case 'maximum':
        return instance.maximum;
      case 'notifications_title':
        return instance.notifications_title;
      case 'no_notifications':
        return instance.no_notifications;
      case 'no_notifications_desc':
        return instance.no_notifications_desc;
      case 'notification_wird_title':
        return instance.notification_wird_title;
      case 'notification_wird_body':
        return instance.notification_wird_body(args?[0] ?? '', args?[1] ?? '');
      case 'back':
        return instance.back;
      case 'new_update':
        return instance.new_update;
      case 'new_features':
        return instance.new_features;
      case 'bug_fixes':
        return instance.bug_fixes;
      case 'update_now_btn':
        return instance.update_now_btn;
      case 'close_btn':
        return instance.close_btn;
      case 'category_all':
        return instance.category_all;
      case 'category_auto_update':
        return instance.category_auto_update;
      case 'category_manual_update':
        return instance.category_manual_update;
      case 'category_maintenance':
        return instance.category_maintenance;
      case 'category_greeting':
        return instance.category_greeting;
      case 'category_exclusive':
        return instance.category_exclusive;
      case 'category_general':
        return instance.category_general;
      case 'search_hint':
        return instance.search_hint;
      case 'all':
        return instance.all;
      case 'update_screen_title':
        return instance.update_screen_title;
      case 'update_available_desc':
        return instance.update_available_desc;
      case 'size_label':
        return instance.size_label;
      case 'downloading_update':
        return instance.downloading_update;
      case 'dont_close_app':
        return instance.dont_close_app;
      case 'update_completed':
        return instance.update_completed;
      case 'restart_to_apply':
        return instance.restart_to_apply;
      case 'up_to_date_title':
        return instance.up_to_date_title;
      case 'no_updates_available':
        return instance.no_updates_available;
      case 'search_again':
        return instance.search_again;
      case 'error_occurred':
        return instance.error_occurred;
      case 'later':
        return instance.later;
      case 'ok':
        return instance.ok;
      case 'mandatory_update':
        return instance.mandatory_update;
      case 'mandatory_update_desc':
        return instance.mandatory_update_desc;
      case 'restart':
        return instance.restart;
      case 'no_update_found':
        return instance.no_update_found;
      case 'latest_version_msg':
        return instance.latest_version_msg;
      case 'update_downloaded_restart':
        return instance.update_downloaded_restart;
      case 'update_complete_msg':
        return instance.update_complete_msg(namedArgs?['title'] ?? '');
      case 'permissions_rationale_title':
        return instance.permissions_rationale_title;
      case 'permissions_rationale_body':
        return instance.permissions_rationale_body;
      case 'couldnt_open_page':
        return instance.couldnt_open_page;
      case 'undo':
        return instance.undo;
      default:
        return key;
    }
  }
}
