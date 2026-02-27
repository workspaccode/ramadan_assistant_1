import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';
import 'package:tafsir_library/tafsir_library.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 1;
  bool _isPlaying = false;
  final AudioService _audioService = AudioService();

  @override
  void dispose() {
    _pageController.dispose();
    _audioService.stop();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index + 1;
      _audioService.stop();
      _isPlaying = false;
    });
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioService.stop();
      setState(() => _isPlaying = false);
    } else {
      // Formats page number to 3 digits e.g., '001', '015', '604'
      final pageNumStr = _currentPage.toString().padLeft(3, '0');
      // Using Husary Mujawwad (Tajweed) from everyayah.com
      // URL format: https://everyayah.com/data/Husary_Mujawwad_64kbps/PageMp3s/Page001.mp3
      final audioUrl =
          'https://everyayah.com/data/Husary_Mujawwad_64kbps/PageMp3s/Page$pageNumStr.mp3';

      setState(() => _isPlaying = true);
      await _audioService.playUrl(audioUrl);

      // Stop playing when done (requires AudioPlayer listener which we might need to update in AudioService)
      // For now, we manually manage it if it stops.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('quran'.tr()),
        leading: GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Icon(Icons.arrow_back, color: theme.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quran Navigation / Info Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Juz ${quran.getJuzNumber(quran.getPageData(_currentPage).first['surah'], quran.getPageData(_currentPage).first['start'])}',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    quran.getSurahNameArabic(
                      quran.getPageData(_currentPage).first['surah'],
                    ),
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri', // Or a suitable Arabic font
                    ),
                  ),
                  Text(
                    'Page $_currentPage',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // The Quran Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                reverse: true, // Arabic reads Right-to-Left
                itemCount: 604, // Total pages in Quran
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final page = index + 1;
                  // The quran package doesn't have built-in UI for full pages.
                  // We get the ayahs for this page and display them.
                  final pageData = quran.getPageData(page);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: RichText(
                      textAlign: TextAlign.justify,
                     // textDirection: TextDirection.RTL,
                      text: TextSpan(
                        children: pageData.expand((data) {
                          final surah = data['surah'];
                          final startAyah = data['start'];
                          final endAyah = data['end'];

                          List<InlineSpan> spans = [];

                          // Add Basmalah if it's the start of a Surah (except Tawbah)
                          if (startAyah == 1 && surah != 1 && surah != 9) {
                            spans.add(
                              TextSpan(
                                text: '${quran.basmala}\n',
                                style: TextStyle(
                                  color: theme.textPrimary,
                                  fontSize: 24,
                                  fontFamily: 'Amiri',
                                  height: 1.8,
                                ),
                              ),
                            );
                          }

                          for (int i = startAyah; i <= endAyah; i++) {
                            spans.add(
                              TextSpan(
                                text:
                                    '${quran.getVerse(surah, i)} ${quran.getVerseEndSymbol(i)} ',
                                style: TextStyle(
                                  color: theme.textPrimary,
                                  fontSize: 24, // Adjust size as needed
                                  fontFamily:
                                      'Amiri', // Strongly recommend using an Arabic font like 'Amiri' or 'Scheherazade'
                                  height: 1.8,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Calculate global ayah number. The quran package does not provide a direct global ayah number,
                                    // but tafsir_library expects 'ayahUQNumber'.
                                    // We can calculate it by summing verse counts of all previous surahs.
                                    int globalAyah = 0;
                                    for (int s = 1; s < surah; s++) {
                                      globalAyah += quran.getVerseCount(s);
                                    }
                                    globalAyah += i;

                                    final isDark =
                                        Theme.of(context).brightness ==
                                        Brightness.dark;

                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        insetPadding: const EdgeInsets.all(16),
                                        child: ShowTafsir(
                                          context: context,
                                          ayahUQNumber: globalAyah,
                                          ayahNumber: i,
                                          pageIndex: page,
                                          isDark: isDark,
                                          surahNumber: surah,
                                        ),
                                      ),
                                    );
                                  },
                              ),
                            );
                          }
                          return spans;
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Audio Player Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.cardSurface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tajweed Recitation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      Text(
                        'Mahmoud Khalil Al-Husary',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  FloatingActionButton(
                    onPressed: _toggleAudio,
                    backgroundColor: theme.primary,
                    elevation: 0,
                    mini: true,
                    child: Icon(
                      _isPlaying
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
