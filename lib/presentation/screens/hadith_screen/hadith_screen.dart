import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/cubits/hadith/hadith_cubit.dart';
import 'package:ramadan_assistant/presentation/cubits/hadith/hadith_state.dart';
import 'package:ramadan_assistant/presentation/screens/hadith_screen/hadith_detail_screen.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  final Map<String, String> _books = {
    // Forties (الأربعينات)
    'الأربعون النووية':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/forties/nawawi40.json',
    'الأربعون القدسية':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/forties/qudsi40.json',
    'أربعون الشاه ولي الله':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/forties/shahwaliullah40.json',

    // The 9 Books (الكتب التسعة)
    'صحيح البخاري':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/the_9_books/bukhari.json',
    'صحيح مسلم':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/the_9_books/muslim.json',
    'سنن أبي داود':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/the_9_books/abudawud.json',
    'جامع الترمذي':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/the_9_books/tirmidhi.json',
    'سنن النسائي':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/the_9_books/nasai.json',
    'سنن ابن ماجه':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/the_9_books/ibnmajah.json',
    'موطأ مالك':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/the_9_books/malik.json',
    'مسند أحمد':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/the_9_books/ahmed.json',
    'سنن الدارمي':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/the_9_books/darimi.json',

    // Other Books (كتب أخرى)
    'رياض الصالحين':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/other_books/riyad_assalihin.json',
    'الشمائل المحمدية':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/other_books/shamail_muhammadiyah.json',
    'بلوغ المرام':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/other_books/bulugh_almaram.json',
    'الأدب المفرد':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/other_books/aladab_almufrad.json',
    'مشكاة المصابيح':
        'https://raw.githubusercontent.com/AhmedBaset/hadith-json/main/db/by_book/other_books/mishkat_almasabih.json',
  };
  late String _selectedBook;

  @override
  void initState() {
    super.initState();
    _selectedBook = _books.keys.first;
    context.read<HadithCubit>().loadHadiths(url: _books[_selectedBook]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: BlocBuilder<HadithCubit, HadithState>(
        builder: (context, state) {
          Widget sliverContent;
          if (state is HadithLoading) {
            sliverContent = const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          } else if (state is HadithError) {
            sliverContent = SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(state.message, textAlign: TextAlign.center),
                ),
              ),
            );
          } else if (state is HadithLoaded) {
            if (state.hadiths.isEmpty) {
              sliverContent = const SliverFillRemaining(
                child: Center(child: Text('لا توجد أحاديث')),
              );
            } else {
              sliverContent = SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final hadith = state.hadiths[index];
                    // iOS grouped style: top rounded, bottom rounded, or all rounded
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: context.theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HadithDetailScreen(hadith: hadith),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  hadith.textAr ?? hadith.textEn ?? 'حديث',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.justify,
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        hadith.source ?? hadith.narrator ?? '',
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: context.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textDirection: TextDirection.rtl,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.bookmark_border,
                                      size: 16,
                                      color: context.primaryColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: state.hadiths.length),
                ),
              );
            }
          } else {
            sliverContent = const SliverFillRemaining(
              child: Center(child: Text('جاري التحميل...')),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                stretch: true,
                elevation: 0,
                backgroundColor: context.backgroundColor.withOpacity(0.8),
                surfaceTintColor: Colors.transparent,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      title: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedBook,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: context.primaryColor,
                          ),
                          dropdownColor: context.theme.cardColor,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null && newValue != _selectedBook) {
                              setState(() {
                                _selectedBook = newValue;
                              });
                              context.read<HadithCubit>().loadHadiths(
                                url: _books[newValue],
                              );
                            }
                          },
                          items: _books.keys.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      centerTitle: false,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: context.primaryColor,
                    ),
                    onPressed: () =>
                        context.read<HadithCubit>().refreshHadiths(),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              sliverContent,
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          );
        },
      ),
    );
  }
}
