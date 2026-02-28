import 'dart:async';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/audio_service.dart';
import 'package:ramadan_assistant/data/local/database/quran_database.dart';

class QuranReciter {
  final String name;
  final String type; // e.g., 'Tajweed Recitation', 'Murattal Recitation'
  final String identifier; // Folder name on EveryAyah
  final bool hasAyahFormat; // True if {surah}{ayah}.mp3 is available
  final bool hasPageFormat; // True if PageMp3s/Page{page}.mp3 is available

  const QuranReciter(
    this.name,
    this.type,
    this.identifier, {
    this.hasAyahFormat = true,
    this.hasPageFormat = false,
  });
}

final List<QuranReciter> availableReciters = [
  const QuranReciter(
    'Mahmoud Khalil Al-Husary',
    'Tajweed Recitation',
    'Husary_Mujawwad_64kbps',
    hasAyahFormat: true,
    hasPageFormat: true,
  ),
  const QuranReciter(
    'Yasser Al-Dussary',
    'Murattal Recitation',
    'Yasser_Ad-Dussary_128kbps',
    hasAyahFormat: true,
    hasPageFormat: false,
  ),
  const QuranReciter(
    'Mishary Rashid Al-Afasy',
    'Murattal Recitation',
    'Alafasy_64kbps',
    hasAyahFormat: true,
    hasPageFormat: true,
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
  StreamSubscription<void>? _playerCompleteSubscription;

  // Ayah-by-Ayah tracking
  VerseEntity? _currentPlayingVerse;
  List<VerseEntity> _currentPageVerses = [];

  QuranReciter _selectedReciter = availableReciters[0];

  @override
  void initState() {
    super.initState();
    _loadSurahs();

    // Listen to player completions to auto-play next verse
    _playerCompleteSubscription = _audioService.onPlayerComplete.listen((_) {
      if (!mounted) return;
      _playNextVerse();
    });
  }

  Future<void> _playNextVerse() async {
    // If the reciter doesn't support ayah format, we play page mode, so this listener shouldn't try to play next verse.
    if (!_selectedReciter.hasAyahFormat) {
      if (_currentPlayingVerse != null) {
        setState(() {
          _isPlaying = false;
          _currentPlayingVerse = null;
        });
      }
      return;
    }

    if (_currentPlayingVerse == null || _currentPageVerses.isEmpty) {
      setState(() => _isPlaying = false);
      return;
    }

    final currentIndex = _currentPageVerses.indexOf(_currentPlayingVerse!);

    // If there is another verse on the SAME page, play it immediately.
    if (currentIndex != -1 && currentIndex < _currentPageVerses.length - 1) {
      final nextVerse = _currentPageVerses[currentIndex + 1];
      _playVerse(nextVerse);
    }
    // If this was the last verse on the page, flip the page and play the first verse of the new page.
    else if (_currentPage < 604) {
      final nextPage = _currentPage + 1;

      _pageController.animateToPage(
        nextPage - 1, // 0-indexed
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // We wait for the page animation and the FutureBuilder to load the new verses,
      // then we find the new first verse and play it.
      Future.delayed(const Duration(milliseconds: 800), () async {
        if (!mounted) return;
        final newVerses = await QuranDatabase.instance.getVersesByPage(
          nextPage,
        );
        if (newVerses.isNotEmpty) {
          _playVerse(newVerses.first);
        }
      });
    } else {
      // End of Quran
      setState(() {
        _isPlaying = false;
        _currentPlayingVerse = null;
      });
    }
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
    _playerCompleteSubscription?.cancel();
    _pageController.dispose();
    _audioService.stop();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index + 1;
      _audioService.stop();
      _isPlaying = false;
      _currentPlayingVerse = null;
    });
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioService.stop();
      setState(() {
        _isPlaying = false;
        _currentPlayingVerse = null;
      });
    } else {
      if (_selectedReciter.hasAyahFormat) {
        // Try to start from the first verse of the current page if none selected
        if (_currentPageVerses.isNotEmpty) {
          _playVerse(_currentPlayingVerse ?? _currentPageVerses.first);
        }
      } else if (_selectedReciter.hasPageFormat) {
        // Play by page
        final pageNumStr = _currentPage.toString().padLeft(3, '0');
        final audioUrl =
            'https://everyayah.com/data/${_selectedReciter.identifier}/PageMp3s/Page$pageNumStr.mp3';

        setState(() => _isPlaying = true);
        await _audioService.playUrl(audioUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'عذراً، التلاوة غير متوفرة حالياً لهذا القارئ (قريباً)',
            ),
          ),
        );
      }
    }
  }

  Future<void> _playVerse(VerseEntity verse) async {
    if (!_selectedReciter.hasAyahFormat) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'التظليل آية بآية غير متوفر حالياً لهذا القارئ (قريباً)',
          ),
        ),
      );
      return;
    }

    setState(() {
      _currentPlayingVerse = verse;
      _isPlaying = true;
    });

    // Format: {surah_number_padded}{ayah_number_padded}.mp3 (e.g., 001001.mp3)
    final surahNumStr = verse.surahNumber.toString().padLeft(3, '0');
    final ayahNumStr = verse.number.toString().padLeft(3, '0');
    final fileName = '$surahNumStr$ayahNumStr.mp3';

    final audioUrl =
        'https://everyayah.com/data/${_selectedReciter.identifier}/$fileName';

    await _audioService.playUrl(audioUrl);
  }

  void showReciterBottomSheet() {
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

  void showIndexBottomSheet(BuildContext context) {
    final theme = context.ramadanTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: theme.cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                TabBar(
                  labelColor: theme.primary,
                  unselectedLabelColor: theme.textSecondary,
                  indicatorColor: theme.primary,
                  labelStyle: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'السور'),
                    Tab(text: 'الأجزاء'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Surahs List
                      ListView.builder(
                        itemCount: _surahs.length,
                        itemBuilder: (context, index) {
                          final surah = _surahs[index];
                          return ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage(
                                    'assets/image/tawaf_round_icon.png',
                                  ), // using existing Islamic pattern
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Text(
                                '${surah.number}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              surah.nameAr,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                                color: theme.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              '${surah.revelationPlaceAr} - آياتها ${surah.versesCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textSecondary,
                              ),
                            ),
                            onTap: () async {
                              final startPage = await QuranDatabase.instance
                                  .getSurahStartPage(surah.number);
                              Navigator.pop(context);
                              _pageController.jumpToPage(startPage - 1);
                            },
                          );
                        },
                      ),
                      // Juz List
                      ListView.builder(
                        itemCount: 30,
                        itemBuilder: (context, index) {
                          final juzNum = index + 1;
                          return ListTile(
                            title: Text(
                              'الجزء ${_getArabicNumber(juzNum)}',
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                                color: theme.textPrimary,
                              ),
                            ),
                            onTap: () async {
                              final startPage = await QuranDatabase.instance
                                  .getJuzStartPage(juzNum);
                              Navigator.pop(context);
                              _pageController.jumpToPage(startPage - 1);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt_rounded, color: theme.primary),
            onPressed: () => showIndexBottomSheet(context),
            tooltip: 'الفهرس',
          ),
        ],
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

                    // Update our page tracking state safely after build
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _currentPage == pageNum) {
                        _currentPageVerses = verses;
                      }
                    });

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
                                  final isActive =
                                      _currentPlayingVerse != null &&
                                      _currentPlayingVerse!.surahNumber ==
                                          verse.surahNumber &&
                                      _currentPlayingVerse!.number ==
                                          verse.number;

                                  return TextSpan(
                                    style: isActive
                                        ? TextStyle(
                                            backgroundColor: theme.primary
                                                .withOpacity(0.2),
                                            color: theme.primary,
                                          )
                                        : null,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _playVerse(verse);
                                      },
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
                onTap: showReciterBottomSheet,
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
