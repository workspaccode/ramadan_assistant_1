import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';
import 'package:ramadan_assistant/data/local/database/quran_database.dart';

class QuranReciter {
  final String name;
  final String type; // e.g., 'Tajweed Recitation', 'Murattal Recitation'
  final String identifier; // Folder name on EveryAyah

  const QuranReciter(this.name, this.type, this.identifier);
}

final List<QuranReciter> availableReciters = [
  const QuranReciter(
    'Mahmoud Khalil Al-Husary',
    'Tajweed Recitation',
    'Husary_Mujawwad_64kbps',
  ),
  const QuranReciter(
    'Yasser Al-Dussary',
    'Murattal Recitation',
    'Yasser_Ad-Dussary_128kbps', // not available
  ),
  const QuranReciter(
    'Mishary Rashid Al-Afasy',
    'Murattal Recitation',
    'Alafasy_64kbps',
  ),
];

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
  List<SurahEntity> _surahs = [];

  QuranReciter _selectedReciter = availableReciters[0];

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    final surahs = await QuranDatabase.instance.getAllSurahs();
    if (mounted) {
      setState(() => _surahs = surahs);
    }
  }

  String _getArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((e) => arabicDigits[int.parse(e)])
        .join('');
  }

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
      final audioUrl =
          'https://everyayah.com/data/${_selectedReciter.identifier}/PageMp3s/Page$pageNumStr.mp3';

      setState(() => _isPlaying = true);
      await _audioService.playUrl(audioUrl);

      // Stop playing when done (requires AudioPlayer listener which we might need to update in AudioService)
      // For now, we manually manage it if it stops.
    }
  }

  void _showReciterBottomSheet() {
    final theme = context.ramadanTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(Icons.record_voice_over_rounded, color: theme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Select Reciter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Reciters List
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: availableReciters.length,
                  itemBuilder: (context, index) {
                    final reciter = availableReciters[index];
                    final isSelected = reciter == _selectedReciter;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      title: Text(
                        reciter.name,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? theme.primary : theme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        reciter.type,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textSecondary,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: theme.primary,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedReciter = reciter;
                        });
                        // If already playing, stop current and start new
                        if (_isPlaying) {
                          _audioService.stop().then((_) {
                            setState(() => _isPlaying = false);
                            _toggleAudio(); // Restart with new reciter
                          });
                        }
                        context.pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;

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
        child: Stack(
          children: [
            // The Custom Offline Quran UI will go here
            PageView.builder(
              controller: _pageController,
              itemCount: 604,
              reverse: true, // Right to left scrolling for Arabic
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final pageNum = index + 1;
                return FutureBuilder<List<VerseEntity>>(
                  future: QuranDatabase.instance.getVersesByPage(pageNum),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading page'));
                    }

                    final verses = snapshot.data ?? [];
                    if (verses.isEmpty) {
                      return const Center(
                        child: Text('No verses found on this page'),
                      );
                    }

                    final firstVerse = verses.first;
                    final surah = _surahs.isNotEmpty
                        ? _surahs.firstWhere(
                            (s) => s.number == firstVerse.surahNumber,
                            orElse: () => _surahs.first,
                          )
                        : null;

                    return Column(
                      children: [
                        // Page Header (Juz & Surah)
                        if (surah != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.cardSurface,
                              border: Border(
                                bottom: BorderSide(
                                  color: theme.borderColor.withOpacity(0.1),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الجزء ${_getArabicNumber(firstVerse.juz)}',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 16,
                                    color: theme.textSecondary,
                                  ),
                                ),
                                Text(
                                  surah.nameAr,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 24,
                              bottom: 120, // space for bottom player
                            ),
                            child: RichText(
                              textAlign: TextAlign.justify,
                              textDirection: ui.TextDirection.rtl,
                              text: TextSpan(
                                style: GoogleFonts.amiriQuran(
                                  fontSize: 26,
                                  height: 2.2,
                                  color: theme.textPrimary,
                                ),
                                children: verses.map((verse) {
                                  return TextSpan(
                                    children: [
                                      TextSpan(text: verse.textAr),
                                      TextSpan(
                                        text:
                                            ' \uFD3F${_getArabicNumber(verse.number)}\uFD3E ',
                                        style: TextStyle(
                                          color: theme.primary.withOpacity(0.8),
                                          fontSize:
                                              22, // slightly smaller verse brackets
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        // Page Footer (Number)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 90.0,
                          ), // Above the player
                          child: Text(
                            _getArabicNumber(pageNum),
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              color: theme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            // Our Floating Audio Player Bar
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: GestureDetector(
                onTap: _showReciterBottomSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _selectedReciter.type,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: theme.textSecondary,
                                ),
                              ],
                            ),
                            Text(
                              _selectedReciter.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textSecondary,
                              ),
                            ),
                          ],
                        ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
