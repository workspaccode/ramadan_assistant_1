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

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

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

  /// No description provided for @got_it.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get got_it;

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

  /// No description provided for @umrah_title.
  ///
  /// In en, this message translates to:
  /// **'Umrah Guide'**
  String get umrah_title;

  /// No description provided for @umrah_progress_label.
  ///
  /// In en, this message translates to:
  /// **'Umrah Progress'**
  String get umrah_progress_label;

  /// No description provided for @current_stage.
  ///
  /// In en, this message translates to:
  /// **'Current Stage'**
  String get current_stage;

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

  /// No description provided for @tajweed_enabled.
  ///
  /// In en, this message translates to:
  /// **'Color Tajweed Enabled'**
  String get tajweed_enabled;

  /// No description provided for @tajweed_disabled.
  ///
  /// In en, this message translates to:
  /// **'Color Tajweed Disabled'**
  String get tajweed_disabled;

  /// No description provided for @tajweed_rules.
  ///
  /// In en, this message translates to:
  /// **'Tajweed Rules'**
  String get tajweed_rules;

  /// No description provided for @play_recitation.
  ///
  /// In en, this message translates to:
  /// **'Play Recitation'**
  String get play_recitation;

  /// No description provided for @stop_recitation.
  ///
  /// In en, this message translates to:
  /// **'Stop Recitation'**
  String get stop_recitation;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @complete_button.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get complete_button;

  /// No description provided for @next_step.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get next_step;

  /// No description provided for @guidelines_title.
  ///
  /// In en, this message translates to:
  /// **'Guidelines'**
  String get guidelines_title;

  /// No description provided for @adhkar_title.
  ///
  /// In en, this message translates to:
  /// **'Adhkar'**
  String get adhkar_title;

  /// No description provided for @step_ihram.
  ///
  /// In en, this message translates to:
  /// **'Ihram'**
  String get step_ihram;

  /// No description provided for @guide_ihram_1.
  ///
  /// In en, this message translates to:
  /// **'Niyyah (Intention)'**
  String get guide_ihram_1;

  /// No description provided for @guide_ihram_2.
  ///
  /// In en, this message translates to:
  /// **'Miqat (Boundary)'**
  String get guide_ihram_2;

  /// No description provided for @guide_ihram_3.
  ///
  /// In en, this message translates to:
  /// **'Taharah (Purification)'**
  String get guide_ihram_3;

  /// No description provided for @guide_ihram_4.
  ///
  /// In en, this message translates to:
  /// **'Ihram Clothing'**
  String get guide_ihram_4;

  /// No description provided for @guide_ihram_5.
  ///
  /// In en, this message translates to:
  /// **'Talbiyah'**
  String get guide_ihram_5;

  /// No description provided for @guide_ihram_6.
  ///
  /// In en, this message translates to:
  /// **'Dua at Ihram'**
  String get guide_ihram_6;

  /// No description provided for @ishtirat_dua.
  ///
  /// In en, this message translates to:
  /// **'Istikhara Dua'**
  String get ishtirat_dua;

  /// No description provided for @dua_ihram_trans.
  ///
  /// In en, this message translates to:
  /// **'O Allah, I intend to perform Umrah, so make it easy for me and accept it from me'**
  String get dua_ihram_trans;

  /// No description provided for @ihram_dua_instruction.
  ///
  /// In en, this message translates to:
  /// **'Say this when intending to enter Ihram'**
  String get ihram_dua_instruction;

  /// No description provided for @step_entrance.
  ///
  /// In en, this message translates to:
  /// **'Entering the Haram Mosque'**
  String get step_entrance;

  /// No description provided for @guide_entrance_1.
  ///
  /// In en, this message translates to:
  /// **'Enter with the right foot'**
  String get guide_entrance_1;

  /// No description provided for @guide_entrance_2.
  ///
  /// In en, this message translates to:
  /// **'Say: Allahumma salli ala Muhammad'**
  String get guide_entrance_2;

  /// No description provided for @guide_entrance_3.
  ///
  /// In en, this message translates to:
  /// **'Dua upon entering the mosque'**
  String get guide_entrance_3;

  /// No description provided for @step_tawaf.
  ///
  /// In en, this message translates to:
  /// **'Tawaf (Circumambulation)'**
  String get step_tawaf;

  /// No description provided for @guide_tawaf_1.
  ///
  /// In en, this message translates to:
  /// **'Start from the Black Stone'**
  String get guide_tawaf_1;

  /// No description provided for @guide_tawaf_2.
  ///
  /// In en, this message translates to:
  /// **'Circumambulate seven times'**
  String get guide_tawaf_2;

  /// No description provided for @guide_tawaf_3.
  ///
  /// In en, this message translates to:
  /// **'Touch the Stone or Yemeni Corner if possible'**
  String get guide_tawaf_3;

  /// No description provided for @guide_tawaf_4.
  ///
  /// In en, this message translates to:
  /// **'Supplications during circumambulation'**
  String get guide_tawaf_4;

  /// No description provided for @guide_tawaf_5.
  ///
  /// In en, this message translates to:
  /// **'Pray two Rak\'ahs behind Maqam Ibrahim'**
  String get guide_tawaf_5;

  /// No description provided for @dua_tawaf_trans.
  ///
  /// In en, this message translates to:
  /// **'Our Lord, give us in this world that which is good...'**
  String get dua_tawaf_trans;

  /// No description provided for @tawaf_done.
  ///
  /// In en, this message translates to:
  /// **'✨ Seven laps completed!'**
  String get tawaf_done;

  /// No description provided for @complete_tawaf_first.
  ///
  /// In en, this message translates to:
  /// **'Complete first Tawaf'**
  String get complete_tawaf_first;

  /// No description provided for @step_sai.
  ///
  /// In en, this message translates to:
  /// **'Sa\'i (Walking between Safa & Marwa)'**
  String get step_sai;

  /// No description provided for @guide_sai_1.
  ///
  /// In en, this message translates to:
  /// **'Walk between Safa and Marwa'**
  String get guide_sai_1;

  /// No description provided for @guide_sai_2.
  ///
  /// In en, this message translates to:
  /// **'Start from Safa as per Sunnah'**
  String get guide_sai_2;

  /// No description provided for @guide_sai_3.
  ///
  /// In en, this message translates to:
  /// **'Complete seven laps in total'**
  String get guide_sai_3;

  /// No description provided for @guide_sai_4.
  ///
  /// In en, this message translates to:
  /// **'Supplications on Safa and Marwa'**
  String get guide_sai_4;

  /// No description provided for @guide_sai_5.
  ///
  /// In en, this message translates to:
  /// **'Jog between the green markers'**
  String get guide_sai_5;

  /// No description provided for @dua_sai_trans.
  ///
  /// In en, this message translates to:
  /// **'Indeed, Safa and Marwa are among the symbols of Allah'**
  String get dua_sai_trans;

  /// No description provided for @sai_done.
  ///
  /// In en, this message translates to:
  /// **'✨ Seven laps of Sa\'i done!'**
  String get sai_done;

  /// No description provided for @sai_lap_count.
  ///
  /// In en, this message translates to:
  /// **'Lap {current} of {total}'**
  String sai_lap_count(String current, String total);

  /// No description provided for @going_to_marwa.
  ///
  /// In en, this message translates to:
  /// **'Going to Marwa'**
  String get going_to_marwa;

  /// No description provided for @going_to_safa.
  ///
  /// In en, this message translates to:
  /// **'Going to Safa'**
  String get going_to_safa;

  /// No description provided for @auto_tracking_title.
  ///
  /// In en, this message translates to:
  /// **'Auto-tracking for Sa\'i'**
  String get auto_tracking_title;

  /// No description provided for @auto_tracking_active.
  ///
  /// In en, this message translates to:
  /// **'Tracking your location between Safa and Marwa'**
  String get auto_tracking_active;

  /// No description provided for @auto_tracking_inactive.
  ///
  /// In en, this message translates to:
  /// **'Enable tracking to count laps automatically'**
  String get auto_tracking_inactive;

  /// No description provided for @dhikr_standing.
  ///
  /// In en, this message translates to:
  /// **'Dhikr While Standing'**
  String get dhikr_standing;

  /// No description provided for @dhikr_safa_marwa_standing_trans.
  ///
  /// In en, this message translates to:
  /// **'Allah is Greatest, Allah is Greatest, Allah is Greatest. There is no god but Allah alone, He has no partner...'**
  String get dhikr_safa_marwa_standing_trans;

  /// No description provided for @dhikr_walking.
  ///
  /// In en, this message translates to:
  /// **'Dhikr While Walking'**
  String get dhikr_walking;

  /// No description provided for @dua_rabbana_atina_trans.
  ///
  /// In en, this message translates to:
  /// **'Our Lord, give us in this world that which is good and in the Hereafter that which is good, and protect us from the punishment of the Fire'**
  String get dua_rabbana_atina_trans;

  /// No description provided for @dua_rabbi_ighfir_trans.
  ///
  /// In en, this message translates to:
  /// **'My Lord, forgive and have mercy, and pass over what You know, for You are the Most Mighty, the Most Noble'**
  String get dua_rabbi_ighfir_trans;

  /// No description provided for @dua_allahumma_inni_asaluka_trans.
  ///
  /// In en, this message translates to:
  /// **'O Allah, I ask You for guidance, piety, chastity and wealth'**
  String get dua_allahumma_inni_asaluka_trans;

  /// No description provided for @step_tahlul.
  ///
  /// In en, this message translates to:
  /// **'Tahlul (Hair Cutting/Shaving)'**
  String get step_tahlul;

  /// No description provided for @guide_tahlul_1.
  ///
  /// In en, this message translates to:
  /// **'Full shaving for men (highly recommended)'**
  String get guide_tahlul_1;

  /// No description provided for @guide_tahlul_2.
  ///
  /// In en, this message translates to:
  /// **'Shortening the hair for men'**
  String get guide_tahlul_2;

  /// No description provided for @guide_tahlul_3.
  ///
  /// In en, this message translates to:
  /// **'Clipping a small portion for women'**
  String get guide_tahlul_3;

  /// No description provided for @fixed_tawaf_sai_duas.
  ///
  /// In en, this message translates to:
  /// **'Fixed Tawaf and Sa\'i Duas'**
  String get fixed_tawaf_sai_duas;

  /// No description provided for @comprehensive_tawaf_duas.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Tawaf Duas'**
  String get comprehensive_tawaf_duas;

  /// No description provided for @comprehensive_sai_duas.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Sa\'i Duas'**
  String get comprehensive_sai_duas;

  /// No description provided for @may_allah_accept_umrah.
  ///
  /// In en, this message translates to:
  /// **'May Allah accept your Umrah 🤲'**
  String get may_allah_accept_umrah;

  /// No description provided for @accept_title.
  ///
  /// In en, this message translates to:
  /// **'Allah accept from you!'**
  String get accept_title;

  /// No description provided for @accept_message.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have completed the Umrah rituals. May Allah accept it from you.'**
  String get accept_message;

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

  /// No description provided for @tab_reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get tab_reminders;

  /// No description provided for @tab_umrah.
  ///
  /// In en, this message translates to:
  /// **'Umrah'**
  String get tab_umrah;

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

  /// No description provided for @no_active_reminders.
  ///
  /// In en, this message translates to:
  /// **'No active reminders'**
  String get no_active_reminders;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @daily_hadith.
  ///
  /// In en, this message translates to:
  /// **'Daily Hadith'**
  String get daily_hadith;

  /// No description provided for @hadith_title.
  ///
  /// In en, this message translates to:
  /// **'Hadith Library'**
  String get hadith_title;

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quran;

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

  /// No description provided for @umrah.
  ///
  /// In en, this message translates to:
  /// **'Umrah'**
  String get umrah;

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

  /// No description provided for @reminders_title.
  ///
  /// In en, this message translates to:
  /// **'Smart Reminders'**
  String get reminders_title;

  /// No description provided for @add_reminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get add_reminder;

  /// No description provided for @no_reminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get no_reminders;

  /// No description provided for @tap_add_dhikr.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a dhikr reminder'**
  String get tap_add_dhikr;

  /// No description provided for @schedule_reminder.
  ///
  /// In en, this message translates to:
  /// **'Schedule Reminder'**
  String get schedule_reminder;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// No description provided for @select_multiple.
  ///
  /// In en, this message translates to:
  /// **'Select multiple (audio will play with slight delay)'**
  String get select_multiple;

  /// No description provided for @offset_seconds.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get offset_seconds;

  /// No description provided for @seconds_after.
  ///
  /// In en, this message translates to:
  /// **'seconds delay'**
  String get seconds_after;

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

  /// No description provided for @audio_settings.
  ///
  /// In en, this message translates to:
  /// **'Audio Settings'**
  String get audio_settings;

  /// No description provided for @fajr_adhan.
  ///
  /// In en, this message translates to:
  /// **'Fajr Adhan'**
  String get fajr_adhan;

  /// No description provided for @other_adhan.
  ///
  /// In en, this message translates to:
  /// **'Other Adhans'**
  String get other_adhan;

  /// No description provided for @fajr_iqama.
  ///
  /// In en, this message translates to:
  /// **'Fajr Iqama'**
  String get fajr_iqama;

  /// No description provided for @other_iqama.
  ///
  /// In en, this message translates to:
  /// **'Other Iqamas'**
  String get other_iqama;

  /// No description provided for @select_sound.
  ///
  /// In en, this message translates to:
  /// **'Select Sound'**
  String get select_sound;

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

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

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

  /// No description provided for @iqama_settings.
  ///
  /// In en, this message translates to:
  /// **'Iqama Settings'**
  String get iqama_settings;

  /// No description provided for @iqama_system.
  ///
  /// In en, this message translates to:
  /// **'Iqama System'**
  String get iqama_system;

  /// No description provided for @system_manual.
  ///
  /// In en, this message translates to:
  /// **'Manual (Custom deltas)'**
  String get system_manual;

  /// No description provided for @system_preset.
  ///
  /// In en, this message translates to:
  /// **'Preset (By region)'**
  String get system_preset;

  /// No description provided for @iqama_preset.
  ///
  /// In en, this message translates to:
  /// **'Iqama Preset'**
  String get iqama_preset;

  /// No description provided for @preset_saudi.
  ///
  /// In en, this message translates to:
  /// **'Saudi Calendar'**
  String get preset_saudi;

  /// No description provided for @preset_egypt.
  ///
  /// In en, this message translates to:
  /// **'Egypt Calendar'**
  String get preset_egypt;

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
  /// **'Reset All Data'**
  String get reset_all_data;

  /// No description provided for @reset_confirmation_msg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all data? This cannot be undone.'**
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

  /// No description provided for @prayer_nearing_title.
  ///
  /// In en, this message translates to:
  /// **'Prayer Time Nearing'**
  String get prayer_nearing_title;

  /// No description provided for @prayer_nearing_body.
  ///
  /// In en, this message translates to:
  /// **'It\'s almost time for {prayer} prayer'**
  String prayer_nearing_body(String prayer);

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

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get minute;

  /// No description provided for @continuous.
  ///
  /// In en, this message translates to:
  /// **'Continuous'**
  String get continuous;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @select_dhikr_prompt.
  ///
  /// In en, this message translates to:
  /// **'Select the dhikr you want to repeat'**
  String get select_dhikr_prompt;

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

  /// No description provided for @stop_adhan.
  ///
  /// In en, this message translates to:
  /// **'Stop Adhan'**
  String get stop_adhan;

  /// No description provided for @notification_adhan_title.
  ///
  /// In en, this message translates to:
  /// **'Time for {prayer} prayer'**
  String notification_adhan_title(String prayer);

  /// No description provided for @notification_adhan_body.
  ///
  /// In en, this message translates to:
  /// **'It is time for the {prayer} prayer.'**
  String notification_adhan_body(String prayer);

  /// No description provided for @open_adhan_btn.
  ///
  /// In en, this message translates to:
  /// **'Open Adhan'**
  String get open_adhan_btn;

  /// No description provided for @dismiss_btn.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss_btn;

  /// No description provided for @notification_iqama_title.
  ///
  /// In en, this message translates to:
  /// **'Iqama Reminder'**
  String get notification_iqama_title;

  /// No description provided for @notification_iqama_body.
  ///
  /// In en, this message translates to:
  /// **'It is time for {prayer} Iqama.'**
  String notification_iqama_body(String prayer);

  /// No description provided for @notification_dhikr_title.
  ///
  /// In en, this message translates to:
  /// **'Dhikr Reminder'**
  String get notification_dhikr_title;

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

  /// No description provided for @audio_not_available.
  ///
  /// In en, this message translates to:
  /// **'Sorry, recitation is currently unavailable for this reciter (coming soon)'**
  String get audio_not_available;

  /// No description provided for @ayah_highlighting_not_available.
  ///
  /// In en, this message translates to:
  /// **'Ayah-by-ayah highlighting is currently unavailable for this reciter (coming soon)'**
  String get ayah_highlighting_not_available;

  /// No description provided for @select_reciter.
  ///
  /// In en, this message translates to:
  /// **'Select Reciter'**
  String get select_reciter;

  /// No description provided for @surahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get surahs;

  /// No description provided for @juzs.
  ///
  /// In en, this message translates to:
  /// **'Juzs'**
  String get juzs;

  /// No description provided for @juz_number.
  ///
  /// In en, this message translates to:
  /// **'Juz {number}'**
  String juz_number(String number);

  /// No description provided for @verses_count.
  ///
  /// In en, this message translates to:
  /// **'{count} Verses'**
  String verses_count(String count);

  /// No description provided for @umrah_date_picker_help.
  ///
  /// In en, this message translates to:
  /// **'Select Umrah Start Date'**
  String get umrah_date_picker_help;

  /// No description provided for @umrah_time_picker_help.
  ///
  /// In en, this message translates to:
  /// **'Select Umrah Start Time'**
  String get umrah_time_picker_help;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @start_trip.
  ///
  /// In en, this message translates to:
  /// **'Start Trip'**
  String get start_trip;

  /// No description provided for @umrah_and_hajj_rites.
  ///
  /// In en, this message translates to:
  /// **'Umrah & Hajj Rites'**
  String get umrah_and_hajj_rites;

  /// No description provided for @main_services.
  ///
  /// In en, this message translates to:
  /// **'Main Services'**
  String get main_services;

  /// No description provided for @umrah_in_progress.
  ///
  /// In en, this message translates to:
  /// **'Umrah in Progress'**
  String get umrah_in_progress;

  /// No description provided for @start_new_umrah.
  ///
  /// In en, this message translates to:
  /// **'Start a New Umrah Trip'**
  String get start_new_umrah;

  /// No description provided for @hajj.
  ///
  /// In en, this message translates to:
  /// **'Hajj'**
  String get hajj;

  /// No description provided for @visiting_madinah.
  ///
  /// In en, this message translates to:
  /// **'Visiting Madinah'**
  String get visiting_madinah;

  /// No description provided for @trip_history.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get trip_history;

  /// No description provided for @umrah_trip.
  ///
  /// In en, this message translates to:
  /// **'Umrah Trip'**
  String get umrah_trip;

  /// No description provided for @start_prefix.
  ///
  /// In en, this message translates to:
  /// **'Start: {start}'**
  String start_prefix(String start);

  /// No description provided for @end_prefix.
  ///
  /// In en, this message translates to:
  /// **'End: {end}'**
  String end_prefix(String end);

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

  /// No description provided for @time_for_dhikr.
  ///
  /// In en, this message translates to:
  /// **'Time for Dhikr'**
  String get time_for_dhikr;

  /// No description provided for @notification_dhikr_body.
  ///
  /// In en, this message translates to:
  /// **'Tap to view Dhikr and start Tasbih'**
  String get notification_dhikr_body;

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

  /// No description provided for @manage_alerts.
  ///
  /// In en, this message translates to:
  /// **'Manage Alerts'**
  String get manage_alerts;

  /// No description provided for @prayer_alerts.
  ///
  /// In en, this message translates to:
  /// **'Prayer Alerts'**
  String get prayer_alerts;

  /// No description provided for @adhan_alerts.
  ///
  /// In en, this message translates to:
  /// **'Adhan Alerts'**
  String get adhan_alerts;

  /// No description provided for @adhan_alerts_desc.
  ///
  /// In en, this message translates to:
  /// **'Play Adhan when prayer time starts'**
  String get adhan_alerts_desc;

  /// No description provided for @iqama_alerts.
  ///
  /// In en, this message translates to:
  /// **'Iqama Alerts'**
  String get iqama_alerts;

  /// No description provided for @iqama_alerts_desc.
  ///
  /// In en, this message translates to:
  /// **'Alert when Iqama time is near'**
  String get iqama_alerts_desc;

  /// No description provided for @dhikr_reminders.
  ///
  /// In en, this message translates to:
  /// **'Dhikr Reminders'**
  String get dhikr_reminders;

  /// No description provided for @dhikr_reminders_desc.
  ///
  /// In en, this message translates to:
  /// **'Periodic reminders for Dhikr and Duas'**
  String get dhikr_reminders_desc;

  /// No description provided for @alerts_settings_footer.
  ///
  /// In en, this message translates to:
  /// **'You can control each type of alert separately to ensure your peace and focus.'**
  String get alerts_settings_footer;

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

  /// No description provided for @comprehensive_duas.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Duas'**
  String get comprehensive_duas;

  /// No description provided for @browse_100_duas.
  ///
  /// In en, this message translates to:
  /// **'Browse 100+ Duas'**
  String get browse_100_duas;
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
