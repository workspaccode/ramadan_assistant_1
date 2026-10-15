import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @passed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get passed;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @got_it_continue.
  ///
  /// In en, this message translates to:
  /// **'Got it, Continue'**
  String get got_it_continue;

  /// No description provided for @skip_for_now.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skip_for_now;

  /// No description provided for @coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get coming_soon;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get times;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @step_tawaf.
  ///
  /// In en, this message translates to:
  /// **'Tawaf (Circumambulation)'**
  String get step_tawaf;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @something_went_wrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get something_went_wrong;

  /// No description provided for @error_prefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error_prefix(String error);

  /// No description provided for @tab_prayers.
  ///
  /// In en, this message translates to:
  /// **'Prayers'**
  String get tab_prayers;

  /// No description provided for @tab_tasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tab_tasbih;

  /// No description provided for @tab_adhkar.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get tab_adhkar;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @daily_progress.
  ///
  /// In en, this message translates to:
  /// **'Daily Progress'**
  String get daily_progress;

  /// No description provided for @days_streak.
  ///
  /// In en, this message translates to:
  /// **'Days Streak'**
  String get days_streak;

  /// No description provided for @pages_read.
  ///
  /// In en, this message translates to:
  /// **'Pages Read'**
  String get pages_read;

  /// No description provided for @tasbih_total.
  ///
  /// In en, this message translates to:
  /// **'Tasbih Total'**
  String get tasbih_total;

  /// No description provided for @eid_al_fitr_title.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Fitr Mubarak!'**
  String get eid_al_fitr_title;

  /// No description provided for @eid_al_fitr_message.
  ///
  /// In en, this message translates to:
  /// **'May Allah accept your fasts and prayers. Wishing you a blessed and joyous Eid with your loved ones.'**
  String get eid_al_fitr_message;

  /// No description provided for @eid_al_adha_title.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Adha Mubarak!'**
  String get eid_al_adha_title;

  /// No description provided for @eid_al_adha_message.
  ///
  /// In en, this message translates to:
  /// **'May the blessings of Allah be with you and your family on this holy occasion of sacrifice and faith.'**
  String get eid_al_adha_message;

  /// No description provided for @hijri_new_year_title.
  ///
  /// In en, this message translates to:
  /// **'Happy Hijri New Year!'**
  String get hijri_new_year_title;

  /// No description provided for @hijri_new_year_message.
  ///
  /// In en, this message translates to:
  /// **'Wishing you a year filled with peace, prosperity, and blessings. May it bring us closer to Allah.'**
  String get hijri_new_year_message;

  /// No description provided for @visit_site.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get visit_site;

  /// No description provided for @daily_hadith.
  ///
  /// In en, this message translates to:
  /// **'Daily Hadith'**
  String get daily_hadith;

  /// No description provided for @prayer_times_title.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayer_times_title;

  /// No description provided for @next_prayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get next_prayer;

  /// No description provided for @time_remaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get time_remaining;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @duha.
  ///
  /// In en, this message translates to:
  /// **'Duha'**
  String get duha;

  /// No description provided for @witr.
  ///
  /// In en, this message translates to:
  /// **'Witr'**
  String get witr;

  /// No description provided for @rakats.
  ///
  /// In en, this message translates to:
  /// **'Rakats'**
  String get rakats;

  /// No description provided for @sunnah.
  ///
  /// In en, this message translates to:
  /// **'Sunnah'**
  String get sunnah;

  /// No description provided for @sunnah_status.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Status'**
  String get sunnah_status;

  /// No description provided for @sunnah_prayer.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Prayer'**
  String get sunnah_prayer;

  /// No description provided for @fard_prayer.
  ///
  /// In en, this message translates to:
  /// **'Fard Prayer'**
  String get fard_prayer;

  /// No description provided for @preferred_duas.
  ///
  /// In en, this message translates to:
  /// **'Preferred Duas'**
  String get preferred_duas;

  /// No description provided for @before_prayer.
  ///
  /// In en, this message translates to:
  /// **'Before Prayer'**
  String get before_prayer;

  /// No description provided for @after_prayer.
  ///
  /// In en, this message translates to:
  /// **'After Prayer'**
  String get after_prayer;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get method;

  /// No description provided for @madhab.
  ///
  /// In en, this message translates to:
  /// **'Madhab'**
  String get madhab;

  /// No description provided for @muslimWorldLeague.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get muslimWorldLeague;

  /// No description provided for @ummAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura (Makkah)'**
  String get ummAlQura;

  /// No description provided for @egyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority'**
  String get egyptian;

  /// No description provided for @karachi.
  ///
  /// In en, this message translates to:
  /// **'University of Islamic Sciences, Karachi'**
  String get karachi;

  /// No description provided for @dubai.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get dubai;

  /// No description provided for @qatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get qatar;

  /// No description provided for @kuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get kuwait;

  /// No description provided for @singapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get singapore;

  /// No description provided for @northAmerica.
  ///
  /// In en, this message translates to:
  /// **'ISNA (North America)'**
  String get northAmerica;

  /// No description provided for @method_muslimWorldLeague.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get method_muslimWorldLeague;

  /// No description provided for @method_egyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority'**
  String get method_egyptian;

  /// No description provided for @method_karachi.
  ///
  /// In en, this message translates to:
  /// **'University of Islamic Sciences, Karachi'**
  String get method_karachi;

  /// No description provided for @method_ummAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura, Makkah'**
  String get method_ummAlQura;

  /// No description provided for @method_dubai.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get method_dubai;

  /// No description provided for @method_qatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get method_qatar;

  /// No description provided for @method_kuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get method_kuwait;

  /// No description provided for @method_singapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get method_singapore;

  /// No description provided for @method_northAmerica.
  ///
  /// In en, this message translates to:
  /// **'ISNA (North America)'**
  String get method_northAmerica;

  /// No description provided for @madhab_shafi.
  ///
  /// In en, this message translates to:
  /// **'Shafi (Standard)'**
  String get madhab_shafi;

  /// No description provided for @madhab_hanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get madhab_hanafi;

  /// No description provided for @qibla_title.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qibla_title;

  /// No description provided for @getting_qibla_direction.
  ///
  /// In en, this message translates to:
  /// **'Getting Qibla direction...'**
  String get getting_qibla_direction;

  /// No description provided for @location_error.
  ///
  /// In en, this message translates to:
  /// **'Location Error'**
  String get location_error;

  /// No description provided for @location_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh Location'**
  String get location_refresh;

  /// No description provided for @location_required_msg.
  ///
  /// In en, this message translates to:
  /// **'Location access is required to show Qibla direction.'**
  String get location_required_msg;

  /// No description provided for @ar_mode.
  ///
  /// In en, this message translates to:
  /// **'AR Qibla'**
  String get ar_mode;

  /// No description provided for @ar_not_supported.
  ///
  /// In en, this message translates to:
  /// **'AR is not supported on this device.'**
  String get ar_not_supported;

  /// No description provided for @ar_instruction.
  ///
  /// In en, this message translates to:
  /// **'Look around through your camera to find the Qibla arrow.'**
  String get ar_instruction;

  /// No description provided for @show_compass.
  ///
  /// In en, this message translates to:
  /// **'Show Compass'**
  String get show_compass;

  /// No description provided for @show_map.
  ///
  /// In en, this message translates to:
  /// **'Show Map'**
  String get show_map;

  /// No description provided for @location_error_title.
  ///
  /// In en, this message translates to:
  /// **'Location Error'**
  String get location_error_title;

  /// No description provided for @open_location_settings.
  ///
  /// In en, this message translates to:
  /// **'Open Location Settings'**
  String get open_location_settings;

  /// No description provided for @checking_location.
  ///
  /// In en, this message translates to:
  /// **'Checking location...'**
  String get checking_location;

  /// No description provided for @location_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is denied.'**
  String get location_denied;

  /// No description provided for @location_permanently_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied.'**
  String get location_permanently_denied;

  /// No description provided for @calibrating_compass.
  ///
  /// In en, this message translates to:
  /// **'Calibrating Compass...'**
  String get calibrating_compass;

  /// No description provided for @current_heading.
  ///
  /// In en, this message translates to:
  /// **'Current Heading:'**
  String get current_heading;

  /// No description provided for @north.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get north;

  /// No description provided for @east.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get east;

  /// No description provided for @south.
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get south;

  /// No description provided for @west.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get west;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @tasbih.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tasbih;

  /// No description provided for @prayer_times.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayer_times;

  /// No description provided for @tasbih_title.
  ///
  /// In en, this message translates to:
  /// **'Tasbih Counter'**
  String get tasbih_title;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @reset_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear progress?'**
  String get reset_message;

  /// No description provided for @start_tasbih.
  ///
  /// In en, this message translates to:
  /// **'Start Tasbih'**
  String get start_tasbih;

  /// No description provided for @select_target.
  ///
  /// In en, this message translates to:
  /// **'Select Target'**
  String get select_target;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @tap_to_count_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to start counting'**
  String get tap_to_count_hint;

  /// No description provided for @wird_title.
  ///
  /// In en, this message translates to:
  /// **'Daily Wird (Khatma)'**
  String get wird_title;

  /// No description provided for @wird_plan_selection.
  ///
  /// In en, this message translates to:
  /// **'Select Reading Plan'**
  String get wird_plan_selection;

  /// No description provided for @wird_khatma_plan.
  ///
  /// In en, this message translates to:
  /// **'Khatma Plan'**
  String get wird_khatma_plan;

  /// No description provided for @wird_pages_prayer_plan.
  ///
  /// In en, this message translates to:
  /// **'Pages per Prayer'**
  String get wird_pages_prayer_plan;

  /// No description provided for @wird_juz_plan.
  ///
  /// In en, this message translates to:
  /// **'Juz Plan'**
  String get wird_juz_plan;

  /// No description provided for @wird_khatmas.
  ///
  /// In en, this message translates to:
  /// **'{count} Khatmas per month'**
  String wird_khatmas(String count);

  /// No description provided for @wird_pages_per_prayer.
  ///
  /// In en, this message translates to:
  /// **'{count} pages after each prayer'**
  String wird_pages_per_prayer(String count);

  /// No description provided for @wird_juz_per_day.
  ///
  /// In en, this message translates to:
  /// **'{count} Juz per day'**
  String wird_juz_per_day(String count);

  /// No description provided for @wird_daily_target.
  ///
  /// In en, this message translates to:
  /// **'Current Daily Target: {count} pages'**
  String wird_daily_target(String count);

  /// No description provided for @wird_total_progress.
  ///
  /// In en, this message translates to:
  /// **'Total Progress'**
  String get wird_total_progress;

  /// No description provided for @wird_page_of.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String wird_page_of(String current, String total);

  /// No description provided for @wird_log_progress.
  ///
  /// In en, this message translates to:
  /// **'Log Progress'**
  String get wird_log_progress;

  /// No description provided for @wird_pages_read.
  ///
  /// In en, this message translates to:
  /// **'How many pages did you read today?'**
  String get wird_pages_read;

  /// No description provided for @wird_start_plan.
  ///
  /// In en, this message translates to:
  /// **'Start Plan'**
  String get wird_start_plan;

  /// No description provided for @wird_change_plan.
  ///
  /// In en, this message translates to:
  /// **'Change Plan'**
  String get wird_change_plan;

  /// No description provided for @wird_last_read_page.
  ///
  /// In en, this message translates to:
  /// **'Last page read'**
  String get wird_last_read_page;

  /// No description provided for @wird_continue_reading.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get wird_continue_reading;

  /// No description provided for @wird_daily_log.
  ///
  /// In en, this message translates to:
  /// **'Daily Prayer Log'**
  String get wird_daily_log;

  /// No description provided for @wird_prayer_target.
  ///
  /// In en, this message translates to:
  /// **'Target: {count} p'**
  String wird_prayer_target(String count);

  /// No description provided for @wird_add_pages.
  ///
  /// In en, this message translates to:
  /// **'Add pages'**
  String get wird_add_pages;

  /// No description provided for @wird_tracker.
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get wird_tracker;

  /// No description provided for @wird_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get wird_history;

  /// No description provided for @wird_streak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get wird_streak;

  /// No description provided for @wird_total_pages.
  ///
  /// In en, this message translates to:
  /// **'Total Pages'**
  String get wird_total_pages;

  /// No description provided for @wird_weekly_activity.
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get wird_weekly_activity;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @light_mode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get light_mode;

  /// No description provided for @enable_dark_theme.
  ///
  /// In en, this message translates to:
  /// **'Enable Dark Theme'**
  String get enable_dark_theme;

  /// No description provided for @color_palette.
  ///
  /// In en, this message translates to:
  /// **'Color Palette'**
  String get color_palette;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @emerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald Gold'**
  String get emerald;

  /// No description provided for @midnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight Royal'**
  String get midnight;

  /// No description provided for @desert.
  ///
  /// In en, this message translates to:
  /// **'Desert Rose'**
  String get desert;

  /// No description provided for @ocean.
  ///
  /// In en, this message translates to:
  /// **'Ocean Calm'**
  String get ocean;

  /// No description provided for @font_size.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get font_size;

  /// No description provided for @font_size_preview.
  ///
  /// In en, this message translates to:
  /// **'Bismillah - Font Size Preview'**
  String get font_size_preview;

  /// No description provided for @current_location.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get current_location;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @app_icon.
  ///
  /// In en, this message translates to:
  /// **'App Icon'**
  String get app_icon;

  /// No description provided for @select_icon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get select_icon;

  /// No description provided for @ramadanClassic.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Classic'**
  String get ramadanClassic;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @global_notifications.
  ///
  /// In en, this message translates to:
  /// **'Global Notifications'**
  String get global_notifications;

  /// No description provided for @enable_all_notifications.
  ///
  /// In en, this message translates to:
  /// **'Enable All Notifications'**
  String get enable_all_notifications;

  /// No description provided for @hijri_calendar.
  ///
  /// In en, this message translates to:
  /// **'Hijri Calendar'**
  String get hijri_calendar;

  /// No description provided for @hijri_adjustment.
  ///
  /// In en, this message translates to:
  /// **'Hijri Adjustment'**
  String get hijri_adjustment;

  /// No description provided for @day_adjustment.
  ///
  /// In en, this message translates to:
  /// **'{count} day(s)'**
  String day_adjustment(String count);

  /// No description provided for @adhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get adhan;

  /// No description provided for @iqama.
  ///
  /// In en, this message translates to:
  /// **'Iqama'**
  String get iqama;

  /// No description provided for @other_prayers.
  ///
  /// In en, this message translates to:
  /// **'Other Prayers'**
  String get other_prayers;

  /// No description provided for @ramadan_kareem.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Kareem'**
  String get ramadan_kareem;

  /// No description provided for @tap_for_blessing.
  ///
  /// In en, this message translates to:
  /// **'Tap for blessing ✨'**
  String get tap_for_blessing;

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Assistant'**
  String get app_name;

  /// No description provided for @app_desc.
  ///
  /// In en, this message translates to:
  /// **'Your companion for Ramadan and beyond. May Allah accept your worship. 🌙'**
  String get app_desc;

  /// No description provided for @app_version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String app_version(String version);

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @check_for_updates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get check_for_updates;

  /// No description provided for @checking_updates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get checking_updates;

  /// No description provided for @reset_all_data.
  ///
  /// In en, this message translates to:
  /// **'Restore default settings'**
  String get reset_all_data;

  /// No description provided for @reset_confirmation_msg.
  ///
  /// In en, this message translates to:
  /// **'Restore prayer, alert and appearance settings? Worship records and appointments will be kept.'**
  String get reset_confirmation_msg;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @about_app.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get about_app;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @terms_of_service.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms_of_service;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @fajr_dua_1.
  ///
  /// In en, this message translates to:
  /// **'O Allah, by Your leave we have reached the morning and by Your leave we reach the evening'**
  String get fajr_dua_1;

  /// No description provided for @fajr_dua_2.
  ///
  /// In en, this message translates to:
  /// **'O Allah, I ask You for beneficial knowledge, good provision, and accepted deeds'**
  String get fajr_dua_2;

  /// No description provided for @dhuhr_dua_1.
  ///
  /// In en, this message translates to:
  /// **'O Allah, forgive me my sins and mistakes'**
  String get dhuhr_dua_1;

  /// No description provided for @dhuhr_dua_2.
  ///
  /// In en, this message translates to:
  /// **'O Allah, bless me in my family and wealth'**
  String get dhuhr_dua_2;

  /// No description provided for @asr_dua_1.
  ///
  /// In en, this message translates to:
  /// **'O Allah, do not leave me to my self even for the blink of an eye'**
  String get asr_dua_1;

  /// No description provided for @asr_dua_2.
  ///
  /// In en, this message translates to:
  /// **'O Allah, I seek refuge in You from anxiety and sorrow'**
  String get asr_dua_2;

  /// No description provided for @maghrib_dua_1.
  ///
  /// In en, this message translates to:
  /// **'O Allah, this is the coming of Your night and the departure of Your day'**
  String get maghrib_dua_1;

  /// No description provided for @maghrib_dua_2.
  ///
  /// In en, this message translates to:
  /// **'O Allah, I ask You for the good of this night'**
  String get maghrib_dua_2;

  /// No description provided for @isha_dua_1.
  ///
  /// In en, this message translates to:
  /// **'O Allah, I ask You for Paradise and seek refuge in You from the Fire'**
  String get isha_dua_1;

  /// No description provided for @isha_dua_2.
  ///
  /// In en, this message translates to:
  /// **'O Allah, protect me from the torment of the grave'**
  String get isha_dua_2;

  /// No description provided for @prayer_time.
  ///
  /// In en, this message translates to:
  /// **'Prayer Time'**
  String get prayer_time;

  /// No description provided for @fard.
  ///
  /// In en, this message translates to:
  /// **'Fard'**
  String get fard;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @subhanAllah.
  ///
  /// In en, this message translates to:
  /// **'SubhanAllah'**
  String get subhanAllah;

  /// No description provided for @tap_to_count.
  ///
  /// In en, this message translates to:
  /// **'Tap to count'**
  String get tap_to_count;

  /// No description provided for @dhikr_list.
  ///
  /// In en, this message translates to:
  /// **'Dhikr List'**
  String get dhikr_list;

  /// No description provided for @reward_astaghfirullah.
  ///
  /// In en, this message translates to:
  /// **'Reward for Astaghfirullah'**
  String get reward_astaghfirullah;

  /// No description provided for @salawat.
  ///
  /// In en, this message translates to:
  /// **'Salawat'**
  String get salawat;

  /// No description provided for @reward_salawat.
  ///
  /// In en, this message translates to:
  /// **'Reward for Salawat'**
  String get reward_salawat;

  /// No description provided for @subhanallah_wabihamdihi.
  ///
  /// In en, this message translates to:
  /// **'SubhanAllahi wa bihamdihi'**
  String get subhanallah_wabihamdihi;

  /// No description provided for @reward_wabihamdihi.
  ///
  /// In en, this message translates to:
  /// **'Reward for SubhanAllahi wa bihamdihi'**
  String get reward_wabihamdihi;

  /// No description provided for @lahawla.
  ///
  /// In en, this message translates to:
  /// **'La hawla wa la quwwata illa billah'**
  String get lahawla;

  /// No description provided for @reward_lahawla.
  ///
  /// In en, this message translates to:
  /// **'Reward for La hawla wa la quwwata illa billah'**
  String get reward_lahawla;

  /// No description provided for @custom_target.
  ///
  /// In en, this message translates to:
  /// **'Custom Target'**
  String get custom_target;

  /// No description provided for @select_dhikr.
  ///
  /// In en, this message translates to:
  /// **'Select Dhikr'**
  String get select_dhikr;

  /// No description provided for @reward_subhanallah.
  ///
  /// In en, this message translates to:
  /// **'Reward for SubhanAllah'**
  String get reward_subhanallah;

  /// No description provided for @alhamdulillah.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get alhamdulillah;

  /// No description provided for @reward_alhamdulillah.
  ///
  /// In en, this message translates to:
  /// **'Reward for Alhamdulillah'**
  String get reward_alhamdulillah;

  /// No description provided for @allahuAkbar.
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get allahuAkbar;

  /// No description provided for @reward_allahuakbar.
  ///
  /// In en, this message translates to:
  /// **'Reward for Allahu Akbar'**
  String get reward_allahuakbar;

  /// No description provided for @laIlahaIllallah.
  ///
  /// In en, this message translates to:
  /// **'La ilaha illallah'**
  String get laIlahaIllallah;

  /// No description provided for @reward_lailahaillallah.
  ///
  /// In en, this message translates to:
  /// **'Reward for La ilaha illallah'**
  String get reward_lailahaillallah;

  /// No description provided for @astaghfirullah.
  ///
  /// In en, this message translates to:
  /// **'Astaghfirullah'**
  String get astaghfirullah;

  /// No description provided for @wird_log_past_day.
  ///
  /// In en, this message translates to:
  /// **'Log Past Day'**
  String get wird_log_past_day;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @wird_error_loading_history.
  ///
  /// In en, this message translates to:
  /// **'Error loading history'**
  String get wird_error_loading_history;

  /// No description provided for @wird_avg_per_day.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get wird_avg_per_day;

  /// No description provided for @wird_details_for.
  ///
  /// In en, this message translates to:
  /// **'Details for'**
  String get wird_details_for;

  /// No description provided for @wird_no_data_day.
  ///
  /// In en, this message translates to:
  /// **'No data for this day'**
  String get wird_no_data_day;

  /// No description provided for @duha_dua_1.
  ///
  /// In en, this message translates to:
  /// **'O Allah, by You we have reached morning and by You we reach evening'**
  String get duha_dua_1;

  /// No description provided for @duha_dua_2.
  ///
  /// In en, this message translates to:
  /// **'O Allah, I ask You for the good of this day and protection from evil'**
  String get duha_dua_2;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @maximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @no_notifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get no_notifications;

  /// No description provided for @no_notifications_desc.
  ///
  /// In en, this message translates to:
  /// **'You will see your update history and alerts here'**
  String get no_notifications_desc;

  /// No description provided for @notification_wird_title.
  ///
  /// In en, this message translates to:
  /// **'Daily Wird Reminder'**
  String get notification_wird_title;

  /// No description provided for @notification_wird_body.
  ///
  /// In en, this message translates to:
  /// **'Do not forget to read your {pages} pages for {prayer} prayer.'**
  String notification_wird_body(String pages, String prayer);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @new_update.
  ///
  /// In en, this message translates to:
  /// **'New Update Available'**
  String get new_update;

  /// No description provided for @new_features.
  ///
  /// In en, this message translates to:
  /// **'What\'s New'**
  String get new_features;

  /// No description provided for @bug_fixes.
  ///
  /// In en, this message translates to:
  /// **'Bug Fixes'**
  String get bug_fixes;

  /// No description provided for @update_now_btn.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get update_now_btn;

  /// No description provided for @close_btn.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close_btn;

  /// No description provided for @category_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get category_all;

  /// No description provided for @category_auto_update.
  ///
  /// In en, this message translates to:
  /// **'Auto Updates'**
  String get category_auto_update;

  /// No description provided for @category_manual_update.
  ///
  /// In en, this message translates to:
  /// **'Store Updates'**
  String get category_manual_update;

  /// No description provided for @category_maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get category_maintenance;

  /// No description provided for @category_greeting.
  ///
  /// In en, this message translates to:
  /// **'Greetings'**
  String get category_greeting;

  /// No description provided for @category_exclusive.
  ///
  /// In en, this message translates to:
  /// **'Exclusive'**
  String get category_exclusive;

  /// No description provided for @category_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get category_general;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for Dua or Dhikr...'**
  String get search_hint;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @update_screen_title.
  ///
  /// In en, this message translates to:
  /// **'App Update'**
  String get update_screen_title;

  /// No description provided for @update_available_desc.
  ///
  /// In en, this message translates to:
  /// **'A new update is available for the app'**
  String get update_available_desc;

  /// No description provided for @size_label.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size_label;

  /// No description provided for @downloading_update.
  ///
  /// In en, this message translates to:
  /// **'Downloading update...'**
  String get downloading_update;

  /// No description provided for @dont_close_app.
  ///
  /// In en, this message translates to:
  /// **'Please don\'t close the app'**
  String get dont_close_app;

  /// No description provided for @update_completed.
  ///
  /// In en, this message translates to:
  /// **'Update completed successfully!'**
  String get update_completed;

  /// No description provided for @restart_to_apply.
  ///
  /// In en, this message translates to:
  /// **'Restart the app to apply the changes'**
  String get restart_to_apply;

  /// No description provided for @up_to_date_title.
  ///
  /// In en, this message translates to:
  /// **'You are using the latest version ✅'**
  String get up_to_date_title;

  /// No description provided for @no_updates_available.
  ///
  /// In en, this message translates to:
  /// **'No updates are currently available'**
  String get no_updates_available;

  /// No description provided for @search_again.
  ///
  /// In en, this message translates to:
  /// **'Search Again'**
  String get search_again;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error_occurred;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @mandatory_update.
  ///
  /// In en, this message translates to:
  /// **'Mandatory Update'**
  String get mandatory_update;

  /// No description provided for @mandatory_update_desc.
  ///
  /// In en, this message translates to:
  /// **'An important security update is available. The update will be downloaded now.'**
  String get mandatory_update_desc;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @no_update_found.
  ///
  /// In en, this message translates to:
  /// **'No Update Available'**
  String get no_update_found;

  /// No description provided for @latest_version_msg.
  ///
  /// In en, this message translates to:
  /// **'You are using the latest version of the app ✅'**
  String get latest_version_msg;

  /// No description provided for @update_downloaded_restart.
  ///
  /// In en, this message translates to:
  /// **'The update was downloaded successfully. Restart the app to apply it.'**
  String get update_downloaded_restart;

  /// No description provided for @update_complete_msg.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" was downloaded successfully.\nRestart the app to apply the changes.'**
  String update_complete_msg(String title);

  /// No description provided for @permissions_rationale_title.
  ///
  /// In en, this message translates to:
  /// **'Enable Prayer Alerts'**
  String get permissions_rationale_title;

  /// No description provided for @permissions_rationale_body.
  ///
  /// In en, this message translates to:
  /// **'Tawabti needs your location to calculate accurate prayer times and Qibla direction, and notification permission to alert you with adhan on time. You can change these anytime in Settings.'**
  String get permissions_rationale_body;

  /// No description provided for @couldnt_open_page.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open this page. Please check your internet connection and try again later.'**
  String get couldnt_open_page;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @ui_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get ui_home;

  /// No description provided for @ui_brand.
  ///
  /// In en, this message translates to:
  /// **'Tawabti'**
  String get ui_brand;

  /// No description provided for @ui_tasbih_activity.
  ///
  /// In en, this message translates to:
  /// **'Tasbih & activity'**
  String get ui_tasbih_activity;

  /// No description provided for @ui_selected_dhikr.
  ///
  /// In en, this message translates to:
  /// **'Selected dhikr'**
  String get ui_selected_dhikr;

  /// No description provided for @ui_session.
  ///
  /// In en, this message translates to:
  /// **'This session'**
  String get ui_session;

  /// No description provided for @ui_remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get ui_remaining;

  /// No description provided for @ui_activity_history.
  ///
  /// In en, this message translates to:
  /// **'Activity history'**
  String get ui_activity_history;

  /// No description provided for @ui_total_sessions.
  ///
  /// In en, this message translates to:
  /// **'Saved sessions'**
  String get ui_total_sessions;

  /// No description provided for @ui_completed_sessions.
  ///
  /// In en, this message translates to:
  /// **'Completed sessions'**
  String get ui_completed_sessions;

  /// No description provided for @ui_adhkar_library.
  ///
  /// In en, this message translates to:
  /// **'Dhikr & duas'**
  String get ui_adhkar_library;

  /// No description provided for @ui_no_results.
  ///
  /// In en, this message translates to:
  /// **'No results for this search'**
  String get ui_no_results;

  /// No description provided for @ui_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ui_all;

  /// No description provided for @ui_copied.
  ///
  /// In en, this message translates to:
  /// **'Dhikr copied'**
  String get ui_copied;

  /// No description provided for @ui_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get ui_copy;

  /// No description provided for @ui_speak.
  ///
  /// In en, this message translates to:
  /// **'Listen to dhikr'**
  String get ui_speak;

  /// No description provided for @ui_saved_dhikr.
  ///
  /// In en, this message translates to:
  /// **'Dhikr in your library'**
  String get ui_saved_dhikr;

  /// No description provided for @ui_listen_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop listening'**
  String get ui_listen_stop;

  /// No description provided for @ui_prayer_settings.
  ///
  /// In en, this message translates to:
  /// **'Prayer times & adhan settings'**
  String get ui_prayer_settings;

  /// No description provided for @ui_your_tools.
  ///
  /// In en, this message translates to:
  /// **'Your daily companion'**
  String get ui_your_tools;

  /// No description provided for @ui_tasbih_category.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get ui_tasbih_category;

  /// No description provided for @ui_salawat_category.
  ///
  /// In en, this message translates to:
  /// **'Salawat'**
  String get ui_salawat_category;

  /// No description provided for @ui_tawheed_category.
  ///
  /// In en, this message translates to:
  /// **'Tawheed'**
  String get ui_tawheed_category;

  /// No description provided for @ui_istighfar_category.
  ///
  /// In en, this message translates to:
  /// **'Istighfar'**
  String get ui_istighfar_category;

  /// No description provided for @ui_dua_category.
  ///
  /// In en, this message translates to:
  /// **'Dua'**
  String get ui_dua_category;

  /// No description provided for @ui_tasbih_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not save this session. Your current count is unchanged.'**
  String get ui_tasbih_save_failed;

  /// No description provided for @ui_daily_tools.
  ///
  /// In en, this message translates to:
  /// **'Daily tools'**
  String get ui_daily_tools;

  /// No description provided for @features_worship.
  ///
  /// In en, this message translates to:
  /// **'Wird & worship'**
  String get features_worship;

  /// No description provided for @features_planner.
  ///
  /// In en, this message translates to:
  /// **'My planner'**
  String get features_planner;

  /// No description provided for @features_library.
  ///
  /// In en, this message translates to:
  /// **'Knowledge library'**
  String get features_library;

  /// No description provided for @features_shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Home shortcuts'**
  String get features_shortcuts;

  /// No description provided for @features_shortcuts_intro.
  ///
  /// In en, this message translates to:
  /// **'Open your favorite tool from your phone’s home screen. Choose a tool, then confirm in the system dialog.'**
  String get features_shortcuts_intro;

  /// No description provided for @features_pin_requested.
  ///
  /// In en, this message translates to:
  /// **'Shortcut requested. Confirm in your phone’s dialog.'**
  String get features_pin_requested;

  /// No description provided for @features_shortcuts_unsupported.
  ///
  /// In en, this message translates to:
  /// **'Pinned shortcuts are unavailable on this device or launcher.'**
  String get features_shortcuts_unsupported;

  /// No description provided for @features_action_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete this action. Try again.'**
  String get features_action_failed;

  /// No description provided for @features_local_data.
  ///
  /// In en, this message translates to:
  /// **'My local data'**
  String get features_local_data;

  /// No description provided for @features_local_intro.
  ///
  /// In en, this message translates to:
  /// **'Your appointments, worship records and favorites are stored on this device. Server sync is not configured yet.'**
  String get features_local_intro;

  /// No description provided for @features_pending_label.
  ///
  /// In en, this message translates to:
  /// **'Records ready for future sync'**
  String get features_pending_label;

  /// No description provided for @features_on_device.
  ///
  /// In en, this message translates to:
  /// **'Saved on device'**
  String get features_on_device;

  /// No description provided for @features_reminder_title.
  ///
  /// In en, this message translates to:
  /// **'Time for your daily wird'**
  String get features_reminder_title;

  /// No description provided for @features_reminder_body.
  ///
  /// In en, this message translates to:
  /// **'Open your reading app, then record your progress in Tawabti.'**
  String get features_reminder_body;

  /// No description provided for @library_title.
  ///
  /// In en, this message translates to:
  /// **'Knowledge library'**
  String get library_title;

  /// No description provided for @library_intro.
  ///
  /// In en, this message translates to:
  /// **'Brief sourced stories and short hadith summaries to read or listen to.'**
  String get library_intro;

  /// No description provided for @library_companions.
  ///
  /// In en, this message translates to:
  /// **'Companion stories'**
  String get library_companions;

  /// No description provided for @library_short_hadith.
  ///
  /// In en, this message translates to:
  /// **'Short hadith summaries'**
  String get library_short_hadith;

  /// No description provided for @library_favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get library_favorites;

  /// No description provided for @library_search.
  ///
  /// In en, this message translates to:
  /// **'Search titles or text'**
  String get library_search;

  /// No description provided for @library_summary_note.
  ///
  /// In en, this message translates to:
  /// **'A summary of the meaning; read the full narration at its source.'**
  String get library_summary_note;

  /// No description provided for @library_source.
  ///
  /// In en, this message translates to:
  /// **'Read source'**
  String get library_source;

  /// No description provided for @library_read_aloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud with device voice'**
  String get library_read_aloud;

  /// No description provided for @library_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop listening'**
  String get library_stop;

  /// No description provided for @library_media.
  ///
  /// In en, this message translates to:
  /// **'Attached media'**
  String get library_media;

  /// No description provided for @library_no_media.
  ///
  /// In en, this message translates to:
  /// **'No media attached. Add an audio, video, or image link for this item.'**
  String get library_no_media;

  /// No description provided for @library_add_media.
  ///
  /// In en, this message translates to:
  /// **'Add media link'**
  String get library_add_media;

  /// No description provided for @library_audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get library_audio;

  /// No description provided for @library_video.
  ///
  /// In en, this message translates to:
  /// **'External video'**
  String get library_video;

  /// No description provided for @library_image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get library_image;

  /// No description provided for @library_link.
  ///
  /// In en, this message translates to:
  /// **'HTTPS link'**
  String get library_link;

  /// No description provided for @library_link_label.
  ///
  /// In en, this message translates to:
  /// **'Link title (optional)'**
  String get library_link_label;

  /// No description provided for @library_invalid_link.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid HTTPS link without a username or password.'**
  String get library_invalid_link;

  /// No description provided for @library_user_media.
  ///
  /// In en, this message translates to:
  /// **'Your attached link; an internet connection is required.'**
  String get library_user_media;

  /// No description provided for @library_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete this change. Try again.'**
  String get library_save_failed;

  /// No description provided for @library_playback_failed.
  ///
  /// In en, this message translates to:
  /// **'Media or device voice could not start. Continue reading or try again.'**
  String get library_playback_failed;

  /// No description provided for @library_remove_media.
  ///
  /// In en, this message translates to:
  /// **'Remove link'**
  String get library_remove_media;

  /// No description provided for @library_favorite_add.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get library_favorite_add;

  /// No description provided for @library_favorite_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get library_favorite_remove;

  /// No description provided for @library_save.
  ///
  /// In en, this message translates to:
  /// **'Save link'**
  String get library_save;

  /// No description provided for @library_no_favorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet. Use the heart on an item to save it here.'**
  String get library_no_favorites;

  /// No description provided for @planner_title.
  ///
  /// In en, this message translates to:
  /// **'My appointments'**
  String get planner_title;

  /// No description provided for @planner_local_hint.
  ///
  /// In en, this message translates to:
  /// **'Your appointments and reminders are stored on this device. Choose a day or add an appointment.'**
  String get planner_local_hint;

  /// No description provided for @planner_add_event.
  ///
  /// In en, this message translates to:
  /// **'Add appointment'**
  String get planner_add_event;

  /// No description provided for @planner_calendar_view.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get planner_calendar_view;

  /// No description provided for @planner_list_view.
  ///
  /// In en, this message translates to:
  /// **'All appointments'**
  String get planner_list_view;

  /// No description provided for @planner_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Room for your next appointment'**
  String get planner_empty_title;

  /// No description provided for @planner_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Add an appointment, its time, and an optional reminder to see it here.'**
  String get planner_empty_body;

  /// No description provided for @planner_title_label.
  ///
  /// In en, this message translates to:
  /// **'Appointment title'**
  String get planner_title_label;

  /// No description provided for @planner_start_label.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get planner_start_label;

  /// No description provided for @planner_end_label.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get planner_end_label;

  /// No description provided for @planner_reminder_label.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get planner_reminder_label;

  /// No description provided for @planner_no_reminder.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get planner_no_reminder;

  /// No description provided for @planner_at_start.
  ///
  /// In en, this message translates to:
  /// **'At the start'**
  String get planner_at_start;

  /// No description provided for @planner_five_minutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes before'**
  String get planner_five_minutes;

  /// No description provided for @planner_ten_minutes.
  ///
  /// In en, this message translates to:
  /// **'10 minutes before'**
  String get planner_ten_minutes;

  /// No description provided for @planner_thirty_minutes.
  ///
  /// In en, this message translates to:
  /// **'30 minutes before'**
  String get planner_thirty_minutes;

  /// No description provided for @planner_hour_before.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get planner_hour_before;

  /// No description provided for @planner_day_before.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get planner_day_before;

  /// No description provided for @planner_notes_label.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get planner_notes_label;

  /// No description provided for @planner_meet_label.
  ///
  /// In en, this message translates to:
  /// **'Google Meet link'**
  String get planner_meet_label;

  /// No description provided for @planner_meet_manual_hint.
  ///
  /// In en, this message translates to:
  /// **'Paste an existing meeting link, or create a meeting in Google Meet and copy its link here. Automatic conference creation inside the app requires Google authorization and is not configured yet.'**
  String get planner_meet_manual_hint;

  /// No description provided for @planner_meet_new.
  ///
  /// In en, this message translates to:
  /// **'Create meeting in browser'**
  String get planner_meet_new;

  /// No description provided for @planner_meet_open.
  ///
  /// In en, this message translates to:
  /// **'Open meeting'**
  String get planner_meet_open;

  /// No description provided for @planner_meet_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the meeting. Check the link and your browser app.'**
  String get planner_meet_failed;

  /// No description provided for @planner_save.
  ///
  /// In en, this message translates to:
  /// **'Save appointment'**
  String get planner_save;

  /// No description provided for @planner_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get planner_edit;

  /// No description provided for @planner_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get planner_delete;

  /// No description provided for @planner_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this local appointment and reminder? Its device calendar copy will remain.'**
  String get planner_delete_confirm;

  /// No description provided for @planner_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get planner_cancel;

  /// No description provided for @planner_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get planner_retry;

  /// No description provided for @planner_event_saved.
  ///
  /// In en, this message translates to:
  /// **'Appointment saved'**
  String get planner_event_saved;

  /// No description provided for @planner_event_deleted.
  ///
  /// In en, this message translates to:
  /// **'Local appointment deleted'**
  String get planner_event_deleted;

  /// No description provided for @planner_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not load appointments. Try again.'**
  String get planner_load_failed;

  /// No description provided for @planner_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the appointment. Your form is preserved; try again.'**
  String get planner_save_failed;

  /// No description provided for @planner_delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel the reminder or delete the appointment. Try again.'**
  String get planner_delete_failed;

  /// No description provided for @planner_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'The appointment is saved, but notifications are not allowed. Enable permission in app settings, then enable its reminder again.'**
  String get planner_permission_denied;

  /// No description provided for @planner_reminder_expired.
  ///
  /// In en, this message translates to:
  /// **'The appointment is saved. Its reminder time has passed; edit the date or choose a reminder closer to its start.'**
  String get planner_reminder_expired;

  /// No description provided for @planner_reminder_failed.
  ///
  /// In en, this message translates to:
  /// **'The appointment is saved, but its reminder was not scheduled. Enable the reminder again.'**
  String get planner_reminder_failed;

  /// No description provided for @planner_reminder_retry.
  ///
  /// In en, this message translates to:
  /// **'Enable reminder'**
  String get planner_reminder_retry;

  /// No description provided for @planner_calendar_connect.
  ///
  /// In en, this message translates to:
  /// **'Connect device calendar'**
  String get planner_calendar_connect;

  /// No description provided for @planner_calendar_hint.
  ///
  /// In en, this message translates to:
  /// **'With your permission, show calendars and accounts on this device. Copy appointments to them or import a local copy. Google account synchronization is managed by device settings.'**
  String get planner_calendar_hint;

  /// No description provided for @planner_calendar_account.
  ///
  /// In en, this message translates to:
  /// **'Calendar and account'**
  String get planner_calendar_account;

  /// No description provided for @planner_calendar_empty.
  ///
  /// In en, this message translates to:
  /// **'No appointments this month in the selected calendar.'**
  String get planner_calendar_empty;

  /// No description provided for @planner_calendar_import.
  ///
  /// In en, this message translates to:
  /// **'Copy to my appointments'**
  String get planner_calendar_import;

  /// No description provided for @planner_calendar_export.
  ///
  /// In en, this message translates to:
  /// **'Save to device calendar'**
  String get planner_calendar_export;

  /// No description provided for @planner_calendar_permission.
  ///
  /// In en, this message translates to:
  /// **'Calendar permission was denied. Enable it in app settings, then connect again.'**
  String get planner_calendar_permission;

  /// No description provided for @planner_calendar_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Device calendar integration is unavailable on this platform. Local appointments remain available.'**
  String get planner_calendar_unavailable;

  /// No description provided for @planner_calendar_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the device calendar operation. Your local appointment was preserved; try again.'**
  String get planner_calendar_failed;

  /// No description provided for @planner_calendar_read_only.
  ///
  /// In en, this message translates to:
  /// **'This calendar is read-only. Select one that allows new appointments.'**
  String get planner_calendar_read_only;

  /// No description provided for @planner_calendar_saved.
  ///
  /// In en, this message translates to:
  /// **'A copy was saved to device calendar'**
  String get planner_calendar_saved;

  /// No description provided for @planner_local_event.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get planner_local_event;

  /// No description provided for @planner_invalid_title.
  ///
  /// In en, this message translates to:
  /// **'Enter an appointment title, up to 160 characters.'**
  String get planner_invalid_title;

  /// No description provided for @planner_invalid_dates.
  ///
  /// In en, this message translates to:
  /// **'The end must be after the start.'**
  String get planner_invalid_dates;

  /// No description provided for @planner_invalid_meet.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid meeting link such as https://meet.google.com/abc-defg-hij'**
  String get planner_invalid_meet;

  /// No description provided for @worship_choose_date.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get worship_choose_date;

  /// No description provided for @worship_title.
  ///
  /// In en, this message translates to:
  /// **'My worship'**
  String get worship_title;

  /// No description provided for @worship_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get worship_today;

  /// No description provided for @worship_wird.
  ///
  /// In en, this message translates to:
  /// **'Quran plan'**
  String get worship_wird;

  /// No description provided for @worship_nawafil.
  ///
  /// In en, this message translates to:
  /// **'Voluntary'**
  String get worship_nawafil;

  /// No description provided for @worship_qada.
  ///
  /// In en, this message translates to:
  /// **'Missed prayers'**
  String get worship_qada;

  /// No description provided for @worship_today_progress.
  ///
  /// In en, this message translates to:
  /// **'{count} of 5 prayers recorded complete'**
  String worship_today_progress(Object count);

  /// No description provided for @worship_manual_hint.
  ///
  /// In en, this message translates to:
  /// **'Record your own worship. Opening a reader never marks your Quran plan complete.'**
  String get worship_manual_hint;

  /// No description provided for @worship_pending.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get worship_pending;

  /// No description provided for @worship_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get worship_completed;

  /// No description provided for @worship_missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get worship_missed;

  /// No description provided for @worship_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get worship_save;

  /// No description provided for @worship_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get worship_cancel;

  /// No description provided for @worship_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get worship_retry;

  /// No description provided for @worship_fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get worship_fajr;

  /// No description provided for @worship_dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get worship_dhuhr;

  /// No description provided for @worship_asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get worship_asr;

  /// No description provided for @worship_maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get worship_maghrib;

  /// No description provided for @worship_isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get worship_isha;

  /// No description provided for @worship_plan_empty.
  ///
  /// In en, this message translates to:
  /// **'Start a reading routine at your own pace.'**
  String get worship_plan_empty;

  /// No description provided for @worship_edit_plan.
  ///
  /// In en, this message translates to:
  /// **'Set reading plan'**
  String get worship_edit_plan;

  /// No description provided for @worship_daily_pages.
  ///
  /// In en, this message translates to:
  /// **'Pages per day'**
  String get worship_daily_pages;

  /// No description provided for @worship_start_page.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get worship_start_page;

  /// No description provided for @worship_reminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get worship_reminder;

  /// No description provided for @worship_reader.
  ///
  /// In en, this message translates to:
  /// **'Quran reader app'**
  String get worship_reader;

  /// No description provided for @worship_no_reader.
  ///
  /// In en, this message translates to:
  /// **'No reader app available'**
  String get worship_no_reader;

  /// No description provided for @worship_pages_range.
  ///
  /// In en, this message translates to:
  /// **'Pages {start}–{end}'**
  String worship_pages_range(Object end, Object start);

  /// No description provided for @worship_wrap_hint.
  ///
  /// In en, this message translates to:
  /// **'Continue at page 1 after page 604.'**
  String get worship_wrap_hint;

  /// No description provided for @worship_open_reader.
  ///
  /// In en, this message translates to:
  /// **'Open reader'**
  String get worship_open_reader;

  /// No description provided for @worship_confirm_reading.
  ///
  /// In en, this message translates to:
  /// **'I finished today’s reading'**
  String get worship_confirm_reading;

  /// No description provided for @worship_reminder_body.
  ///
  /// In en, this message translates to:
  /// **'Your daily Quran reading is ready.'**
  String get worship_reminder_body;

  /// No description provided for @worship_add_voluntary.
  ///
  /// In en, this message translates to:
  /// **'Record voluntary worship'**
  String get worship_add_voluntary;

  /// No description provided for @worship_no_logs.
  ///
  /// In en, this message translates to:
  /// **'Your voluntary prayers and fasting will appear here.'**
  String get worship_no_logs;

  /// No description provided for @worship_duha.
  ///
  /// In en, this message translates to:
  /// **'Duha'**
  String get worship_duha;

  /// No description provided for @worship_witr.
  ///
  /// In en, this message translates to:
  /// **'Witr'**
  String get worship_witr;

  /// No description provided for @worship_rawatib.
  ///
  /// In en, this message translates to:
  /// **'Sunnah prayers'**
  String get worship_rawatib;

  /// No description provided for @worship_nightPrayer.
  ///
  /// In en, this message translates to:
  /// **'Night prayer'**
  String get worship_nightPrayer;

  /// No description provided for @worship_fasting.
  ///
  /// In en, this message translates to:
  /// **'Voluntary fast'**
  String get worship_fasting;

  /// No description provided for @worship_units.
  ///
  /// In en, this message translates to:
  /// **'Rakats'**
  String get worship_units;

  /// No description provided for @worship_note.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get worship_note;

  /// No description provided for @worship_units_value.
  ///
  /// In en, this message translates to:
  /// **'{count} rakats'**
  String worship_units_value(Object count);

  /// No description provided for @worship_qada_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the missed prayers you know about. Today’s records remain separate; no years or obligations are estimated.'**
  String get worship_qada_hint;

  /// No description provided for @worship_opening.
  ///
  /// In en, this message translates to:
  /// **'Enter opening counts'**
  String get worship_opening;

  /// No description provided for @worship_opening_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter a count for each prayer; use 0 if none. Future changes are recorded as adjustments.'**
  String get worship_opening_hint;

  /// No description provided for @worship_remaining.
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String worship_remaining(Object count);

  /// No description provided for @worship_pay.
  ///
  /// In en, this message translates to:
  /// **'Record qada'**
  String get worship_pay;

  /// No description provided for @worship_adjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust count'**
  String get worship_adjust;

  /// No description provided for @worship_count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get worship_count;

  /// No description provided for @worship_adjust_delta.
  ///
  /// In en, this message translates to:
  /// **'Change (+ add / − remove)'**
  String get worship_adjust_delta;

  /// No description provided for @worship_reason.
  ///
  /// In en, this message translates to:
  /// **'Reason for adjustment'**
  String get worship_reason;

  /// No description provided for @worship_history.
  ///
  /// In en, this message translates to:
  /// **'Ledger history'**
  String get worship_history;

  /// No description provided for @worship_no_history.
  ///
  /// In en, this message translates to:
  /// **'No ledger entries yet.'**
  String get worship_no_history;

  /// No description provided for @worship_payment.
  ///
  /// In en, this message translates to:
  /// **'Qada recorded'**
  String get worship_payment;

  /// No description provided for @worship_adjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get worship_adjustment;

  /// No description provided for @worship_opening_event.
  ///
  /// In en, this message translates to:
  /// **'Opening count'**
  String get worship_opening_event;

  /// No description provided for @worship_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get worship_saved;

  /// No description provided for @worship_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your records. Retry.'**
  String get worship_load_failed;

  /// No description provided for @worship_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Your existing records are safe; retry.'**
  String get worship_save_failed;

  /// No description provided for @worship_reminder_failed.
  ///
  /// In en, this message translates to:
  /// **'Plan saved. The reminder could not be scheduled; check notification permissions and save again.'**
  String get worship_reminder_failed;

  /// No description provided for @worship_reader_unavailable.
  ///
  /// In en, this message translates to:
  /// **'The reader could not open. Choose an available app in your plan.'**
  String get worship_reader_unavailable;

  /// No description provided for @worship_invalid_plan.
  ///
  /// In en, this message translates to:
  /// **'Use 1–604 for pages and a valid reminder time.'**
  String get worship_invalid_plan;

  /// No description provided for @worship_invalid_count.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole count from 0 to 1,000,000,000.'**
  String get worship_invalid_count;

  /// No description provided for @worship_invalid_units.
  ///
  /// In en, this message translates to:
  /// **'Enter 1–1000 rakats; a fast is one day.'**
  String get worship_invalid_units;

  /// No description provided for @worship_invalid_day.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid date.'**
  String get worship_invalid_day;

  /// No description provided for @worship_today_only.
  ///
  /// In en, this message translates to:
  /// **'Reading completion can be recorded for today.'**
  String get worship_today_only;

  /// No description provided for @worship_future_day.
  ///
  /// In en, this message translates to:
  /// **'Future worship cannot be marked complete.'**
  String get worship_future_day;

  /// No description provided for @worship_plan_required.
  ///
  /// In en, this message translates to:
  /// **'Set a reading plan first.'**
  String get worship_plan_required;

  /// No description provided for @worship_ledger_initialized.
  ///
  /// In en, this message translates to:
  /// **'Opening counts already exist. Use an adjustment.'**
  String get worship_ledger_initialized;

  /// No description provided for @worship_adjustment_reason.
  ///
  /// In en, this message translates to:
  /// **'Enter a nonzero whole change and explain the adjustment.'**
  String get worship_adjustment_reason;

  /// No description provided for @worship_invalid_note.
  ///
  /// In en, this message translates to:
  /// **'Keep notes within 500 characters.'**
  String get worship_invalid_note;

  /// No description provided for @worship_duplicate_request.
  ///
  /// In en, this message translates to:
  /// **'This action was already recorded with different values.'**
  String get worship_duplicate_request;

  /// No description provided for @worship_opening_required.
  ///
  /// In en, this message translates to:
  /// **'Enter opening counts first.'**
  String get worship_opening_required;

  /// No description provided for @worship_exceeds_remaining.
  ///
  /// In en, this message translates to:
  /// **'This would make the remaining count negative.'**
  String get worship_exceeds_remaining;

  /// No description provided for @planner_calendar_no_accounts.
  ///
  /// In en, this message translates to:
  /// **'No calendars are available on this device. Add an account or calendar in Android settings, then connect again. You can use local appointments now.'**
  String get planner_calendar_no_accounts;

  /// No description provided for @worship_refresh_failed.
  ///
  /// In en, this message translates to:
  /// **'Saved. The updated records could not be loaded; refresh instead of recording again.'**
  String get worship_refresh_failed;

  /// No description provided for @worship_pages_wrap_range.
  ///
  /// In en, this message translates to:
  /// **'Pages {first}, then {second}'**
  String worship_pages_wrap_range(Object first, Object second);

  /// No description provided for @planner_alarm_until_stopped.
  ///
  /// In en, this message translates to:
  /// **'Ring until stopped'**
  String get planner_alarm_until_stopped;

  /// No description provided for @planner_alarm_description.
  ///
  /// In en, this message translates to:
  /// **'The short built-in tone repeats and the device vibrates until you press Stop alarm. Regular reminders remain a single notification.'**
  String get planner_alarm_description;

  /// No description provided for @planner_personal_alarm.
  ///
  /// In en, this message translates to:
  /// **'Appointment alarm'**
  String get planner_personal_alarm;

  /// No description provided for @planner_alarm_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop alarm'**
  String get planner_alarm_stop;

  /// No description provided for @planner_alarm_stop_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not stop the alarm. Try again, or use Stop in its alarm notification.'**
  String get planner_alarm_stop_failed;

  /// No description provided for @sync_title.
  ///
  /// In en, this message translates to:
  /// **'Data sync'**
  String get sync_title;

  /// No description provided for @sync_intro.
  ///
  /// In en, this message translates to:
  /// **'Upload your data to your own server automatically when online. Stays off until you save a URL and token.'**
  String get sync_intro;

  /// No description provided for @sync_url_label.
  ///
  /// In en, this message translates to:
  /// **'Server URL (https)'**
  String get sync_url_label;

  /// No description provided for @sync_token_label.
  ///
  /// In en, this message translates to:
  /// **'Access token'**
  String get sync_token_label;

  /// No description provided for @sync_https_required.
  ///
  /// In en, this message translates to:
  /// **'The URL must start with https://'**
  String get sync_https_required;

  /// No description provided for @sync_token_required.
  ///
  /// In en, this message translates to:
  /// **'Enter the access token'**
  String get sync_token_required;

  /// No description provided for @sync_save.
  ///
  /// In en, this message translates to:
  /// **'Save and enable'**
  String get sync_save;

  /// No description provided for @sync_saved.
  ///
  /// In en, this message translates to:
  /// **'Sync enabled'**
  String get sync_saved;

  /// No description provided for @sync_disable.
  ///
  /// In en, this message translates to:
  /// **'Turn off sync'**
  String get sync_disable;

  /// No description provided for @sync_disabled.
  ///
  /// In en, this message translates to:
  /// **'Sync turned off'**
  String get sync_disabled;

  /// No description provided for @sync_now.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get sync_now;

  /// No description provided for @sync_uploaded.
  ///
  /// In en, this message translates to:
  /// **'{count} records uploaded'**
  String sync_uploaded(int count);

  /// No description provided for @sync_failed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. It will retry when you are back online.'**
  String get sync_failed;

  /// No description provided for @sync_not_configured.
  ///
  /// In en, this message translates to:
  /// **'Sync is not enabled yet'**
  String get sync_not_configured;

  /// No description provided for @library_video_play.
  ///
  /// In en, this message translates to:
  /// **'Play video here'**
  String get library_video_play;

  /// No description provided for @library_video_hide.
  ///
  /// In en, this message translates to:
  /// **'Hide video'**
  String get library_video_hide;

  /// No description provided for @library_video_open_external.
  ///
  /// In en, this message translates to:
  /// **'Open video link'**
  String get library_video_open_external;

  /// No description provided for @library_video_failed.
  ///
  /// In en, this message translates to:
  /// **'This video could not play here. Try opening it in another app.'**
  String get library_video_failed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
