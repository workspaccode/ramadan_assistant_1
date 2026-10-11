# Play Store Readiness & Compliance Report — توبتى (Ramadan Assistant)

> Updated: 2026-09-29 · App version: 2.0.6+1 (pubspec) · Target: Google Play (Android)
> Status: **All code-level blockers and recommendations from the first audit are now FIXED.**
> Only console/hosting actions remain (section 4).

---

## ✅ 1. Fixed Since Last Audit

| # | Was | Fix |
|---|-----|-----|
| **B1** | `applicationId = "com.example.ramadan_assistant"` | ✅ Renamed to **`app.tawabti`** (final Play package). Namespace left as-is so `MainActivity`/R class don't move. `google-services.json` updated to match. ⚠️ Follow-up required — see section 4. |
| **B2** | Release signed with debug keys | ✅ Proper release signing config added to `build.gradle.kts` — reads `android/key.properties` when present, falls back to debug otherwise (dev builds keep working). Created `android/key.properties.example` + `scripts/create_release_keystore.ps1` to generate the keystore interactively. |
| **B3** | Privacy/Terms pages content missing | ✅ `legal/privacy_policy.html` + `legal/terms_of_service.html` created (updated for the new permission set). ⚠️ Hosting still required — see section 4. |
| **B4** | Version hardcoded `2.4.1` in Settings | ✅ Dynamic via `package_info_plus`; pubspec is now `2.0.6+1` (explicit versionCode 1 for the first Play upload). |
| **P1** | `ACCESS_BACKGROUND_LOCATION` + background GPS fix in Workmanager | ✅ **Permission removed.** Background prayer scheduling now uses the **last-known (cached) position** saved during foreground use (`LocationService.getCachedPosition()`). Also fixed a bug where location was fetched *twice* per task. `scheduleNotificationsNow()` falls back to the cache when permission isn't granted yet. |
| **P2** | `SYSTEM_ALERT_WINDOW` adhan overlay (duplicate of full-screen intent) | ✅ **Removed** — permission, `OverlayService`, `overlayMain()`/`AzanOverlayWidget`, all `FlutterOverlayWindow` call sites in `adhan_alarm_service` / `dhikr_alarm_service` / `notification_service`, and the pubspec dependency. The full-screen AdhanScreen + full-screen intent notification covers every case. |
| **UX1** | FCM + location/notification system prompts at cold start (before first frame) | ✅ `FcmService.initialize()` no longer requests permission. New `lib/core/utils/permission_flow.dart` shows a **rationale dialog** (ar/en/ur, skippable) after the home screen's first frame, then requests location → notifications in context. Once granted, it (re)schedules today's prayer notifications. Declining users are never nagged. |
| **UX3** | Overlay entry point not localized | ✅ Moot — overlay removed. |
| **UX4** | `exit(0)` hard process kill after critical update | ✅ Replaced with the user-initiated restart dialog. |
| **UX5** | UpdateScreen always showed Arabic payload (`title_ar`) | ✅ Picks `title_$lang` / `description_$lang` / `changelog_$lang` by saved language, falls back to Arabic → generic key. |
| **UX6** | Dead policy URLs failed silently | ✅ `_launchURL` now shows a localized error dialog if the page can't open. |
| **UX7** | Quran page errors: hardcoded English, no retry | ✅ Localized error + retry button (re-runs the page query). |
| **OSM** | OpenStreetMap tiles without attribution (ODbL requirement) | ✅ "© OpenStreetMap contributors" added to the Qibla map (tappable → copyright page) and Umrah map; `userAgentPackageName` updated to `app.tawabti` in both. |

---

## 📱 2. Current Permission Set (all Play-safe)

| Permission | Purpose | Play Console form |
|---|---|---|
| `INTERNET` | Content fetch, Firebase | None |
| `ACCESS_FINE/COARSE_LOCATION` | Prayer times, Qibla (**while-in-use only**) | Data safety → location collected, not shared |
| `POST_NOTIFICATIONS` | Adhan/iqama/dhikr alerts | Data safety → device IDs / app activity |
| `SCHEDULE_EXACT_ALARM` + `USE_EXACT_ALARM` | Adhan rings at the exact minute | Sensitive permissions form → "alarm app" use case |
| `USE_FULL_SCREEN_INTENT` | Adhan alert over lock screen | Full-screen intent declaration (alarm use case) |
| `FOREGROUND_SERVICE` + `_MEDIA_PLAYBACK` | Adhan audio playback | FGS declaration form + short video |
| `RECEIVE_BOOT_COMPLETED` | Re-arm alarms after reboot | Mention in sensitive permissions form |
| `WAKE_LOCK`, `VIBRATE` | Playback + haptics | None |

**Removed:** `RECORD_AUDIO`, `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`, `ACCESS_BACKGROUND_LOCATION`, `SYSTEM_ALERT_WINDOW`.

Result: **no background-location declaration, no draw-over declaration, no battery-optimization review** — the three hardest review paths are gone.

---

## 📋 3. Play Console Forms — Exact Answers

### Data safety
| Question | Answer |
|---|---|
| Collects/shares required user data? | **Yes** |
| Location (precise) | Collected: **Yes** (while in use, with permission) · Shared: **No** · Purpose: **App functionality** · Processed ephemerally |
| Device/other IDs (FCM token, Firebase install ID) | Collected: **Yes** · Shared: **No** · Purpose: **App functionality** (notifications) |
| App interactions/settings (Remote Config) | Collected: **Yes** · Shared: **No** · Purpose: **App functionality** |
| Encrypted in transit? | **Yes** (HTTPS everywhere) |
| Data deletion? | **Yes** — no accounts; "Reset All Data" in Settings or uninstall deletes everything |
| Families policy | Not for children; target 13+ |

### Content rating (IARC)
Lifestyle/religious app · no UGC, no chat, no ads, no gambling → **Everyone**.

### Declarations to complete
- **Foreground service** (`mediaPlayback`) + video of adhan playing in background.
- **Exact alarms** (`USE_EXACT_ALARM`) — alarm-clock use case (prayer times).
- **Full-screen intent** — alarm-style use case.
- **Shorebird code push** — allowed; disclose a patch framework may deliver bug-fix updates; keep patches non-material.

### Store listing
- [ ] Title **توبتى** (≤30 chars), description in **ar + en**
- [ ] Icon 512×512, feature graphic 1024×500, ≥2 phone screenshots
- [ ] Contact email + site (once `tawabti.app` is live)
- [ ] "Contains ads" = **No** (no ad SDKs in code)

---

## ⚠️ 4. Remaining Actions (cannot be done from the IDE)

1. **Firebase Console** — register the Android app with package **`app.tawabti`**
   in project `apps-41d38` → download the fresh `google-services.json` and replace
   `android/app/google-services.json` (the current file was hand-updated so builds
   work; the console registration makes FCM attribution correct).
2. **Keystore** — run `powershell -ExecutionPolicy Bypass -File scripts/create_release_keystore.ps1`,
   keep `upload-keystore.jks` + passwords backed up, and ensure `android/key.properties`
   and `*.jks` are in `.gitignore`.
3. **Shorebird** — after the package rename you need a **new Shorebird app**
   (`shorebird create app` → replace `app_id` in `shorebird.yaml`) before pushing patches.
4. **Host the legal pages** — `legal/privacy_policy.html` → `https://tawabti.app/privacy`,
   `legal/terms_of_service.html` → `https://tawabti.app/terms`
   (see `legal/README.md` — Firebase Hosting is the fastest option). Update the
   support email inside both pages first.

---

## ✅ 5. Pre-Upload Checklist (in order)

1. [ ] Firebase Console: register `app.tawabti`, replace `google-services.json`
2. [ ] Create release keystore (`scripts/create_release_keystore.ps1`), verify `.gitignore`
3. [ ] New Shorebird app id in `shorebird.yaml`
4. [ ] Host legal pages, set the support email, verify URLs load
5. [ ] `flutter pub get` → `flutter analyze` → `flutter test` (all green)
6. [ ] `flutter build appbundle --release` → upload to **Internal testing**
7. [ ] Fill: Data safety · Content rating · Ads (none) · FGS declaration + video · Sensitive permissions · Store listing (ar+en)
8. [ ] Run the **pre-launch report**, fix anything flagged
9. [ ] Staged rollout: 10% → 50% → 100%

---

## 📁 6. Full Change Log (this pass)

| File | Change |
|---|---|
| `android/app/build.gradle.kts` | applicationId → `app.tawabti`; key.properties-based release signing (debug fallback); comments |
| `android/app/google-services.json` | client package_name → `app.tawabti` (console registration still needed) |
| `android/key.properties.example` | **New** — signing config template |
| `scripts/create_release_keystore.ps1` | **New** — interactive keystore generator |
| `android/app/src/main/AndroidManifest.xml` | Removed `ACCESS_BACKGROUND_LOCATION`, `SYSTEM_ALERT_WINDOW`, OverlayService; updated comments |
| `pubspec.yaml` | version `2.0.6+1`; removed `flutter_overlay_window` |
| `lib/core/services/location_service.dart` | Position caching (`getCachedPosition`) |
| `lib/core/services/background_task_service.dart` | Background task uses cached position (also fixes double-fetch bug); startup fallback |
| `lib/core/services/fcm_service.dart` | No permission prompt at init (status check only) |
| `lib/core/services/adhan_alarm_service.dart` / `dhikr_alarm_service.dart` / `notification_service.dart` | Overlay code removed |
| `lib/core/utils/permission_flow.dart` | **New** — in-context rationale + permission flow |
| `lib/core/utils/smart_update_manager.dart` | `exit(0)` removed |
| `lib/main.dart` | `overlayMain`/`AzanOverlayWidget` removed |
| `lib/presentation/screens/main_screen/widgets/main_screen_content.dart` + `normal_home_content.dart` | Use `PermissionFlow` post-first-frame instead of raw prompts |
| `lib/presentation/screens/update_screen/update_screen.dart` | Language-aware update payload |
| `lib/presentation/screens/settings_screen/widgets/settings_screen_content.dart` | `_launchURL` error dialog |
| `lib/presentation/screens/qibla_screen/widgets/qibla_screen_content.dart` + `umrah_guide_content.dart` | OSM attribution; `userAgentPackageName` → `app.tawabti` |
| `lib/presentation/screens/quran_screen/quran_screen.dart` | Localized error + retry on page load failure |
| `lib/core/l10n/app_{en,ar,ur}.arb` | +`permissions_rationale_*`, +`couldnt_open_page`, −5 unused overlay keys |
| `lib/core/extensions/context_extensions.dart` | Lookup cases updated to match |
| `legal/privacy_policy.html` | Updated: while-in-use location, full-screen intent, no overlay/background location |

*Re-run the Data safety form answers after any future permission or data-flow change.*

---

<!-- Legacy audit sections removed — current state is fully documented above. -->