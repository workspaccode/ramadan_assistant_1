# UI refresh verification

Implemented a shared green/gold visual system with white daytime and black night backgrounds, as requested. Updated normal and Ramadan home layouts, settings surfaces and navigation contrast, home prayer loading/recovery states, reminders empty action, localized reminder intervals, and the daily hadith typography.

## Verified

- `flutter analyze`: no issues.
- `flutter test --dart-define=CAPTURE_UI=true`: 15 tests passed.
- Home layout exercised in Arabic, English and Urdu, light/dark themes, 390 px default and 320 px with 160% text scaling, including scrolling.
- Android debug build succeeded using Gradle with the in-process Kotlin compiler.
- `home-light-render.png` and `home-dark-render.png` are actual raster renders of the production Flutter home widgets, with controlled prayer/location state for testing. They are not AI-generated mockups or screenshots of a running Android device.

## Runtime limitation

The first Android emulator refused installation because its internal storage was almost full. The second emulator remained offline during verification. Android runtime navigation and settings screenshots therefore remain unverified. Existing device data was not deleted.

Existing workspace changes were preserved. Flutter's automatic Gradle property additions were removed after the verification build.
