import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/l10n/app_localizations.dart';
import 'package:ramadan_assistant/core/theme/app_theme.dart';
import 'package:ramadan_assistant/features/library/library_video_player.dart';
import 'package:video_player/video_player.dart';

class _FailingController extends VideoPlayerController {
  _FailingController() : super.networkUrl(Uri.parse('https://x.example/v.mp4'));
  @override
  Future<void> initialize() async => throw StateError('unsupported');
}

void main() {
  test('only direct video files and streams play inline', () {
    for (final ok in [
      'https://a.example/v.mp4',
      'https://a.example/live/index.M3U8',
      'https://a.example/clip.webm?token=1',
    ]) {
      expect(libraryIsDirectVideo(Uri.parse(ok)), isTrue, reason: ok);
    }
    for (final no in [
      'https://www.youtube.com/watch?v=abc',
      'https://a.example/page',
      'https://a.example/audio.mp3',
    ]) {
      expect(libraryIsDirectVideo(Uri.parse(no)), isFalse, reason: no);
    }
  });

  for (final language in ['ar', 'en', 'ur']) {
    testWidgets('failed video shows a recoverable message ($language)', (
      tester,
    ) async {
      var failures = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.getLightTheme(Locale(language)),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                AppLocalizationsLookup.init(context);
                return LibraryVideoPlayer(
                  url: Uri.parse('https://x.example/v.mp4'),
                  onFailed: () => failures++,
                  controllerFactory: (_) => _FailingController(),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(
        find.text(AppLocalizationsLookup.instance.library_video_failed),
        findsOneWidget,
      );
      expect(failures, 1);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }
}
