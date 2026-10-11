import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/data/models/hadith_model.dart';
import 'package:ramadan_assistant/presentation/cubits/hadith/hadith_cubit.dart';
import 'package:ramadan_assistant/presentation/cubits/hadith/hadith_state.dart';
import 'package:ramadan_assistant/presentation/screens/hadith_screen/hadith_detail_screen.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

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
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedBook = _books.keys.first;
    context.read<HadithCubit>().loadHadiths(url: _books[_selectedBook]);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _text(Hadith hadith) {
    final preferred = context.locale.languageCode == 'ar'
        ? hadith.textAr
        : hadith.textEn;
    final fallback = context.locale.languageCode == 'ar'
        ? hadith.textEn
        : hadith.textAr;
    return preferred?.trim().isNotEmpty == true ? preferred! : fallback ?? '';
  }

  void _open(Hadith hadith) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => HadithDetailScreen(hadith: hadith)),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('hadith_title'.tr()),
      actions: [
        IconButton(
          tooltip: 'retry'.tr(),
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => context.read<HadithCubit>().refreshHadiths(
            url: _books[_selectedBook],
          ),
        ),
      ],
    ),
    bottomNavigationBar: const SakinaBottomBar(selectedIndex: 3),
    body: BlocBuilder<HadithCubit, HadithState>(
      builder: (context, state) {
        final hadiths = state is HadithLoaded
            ? state.hadiths
                  .where(
                    (hadith) =>
                        _query.isEmpty ||
                        '${hadith.textAr} ${hadith.textEn} ${hadith.narrator} ${hadith.source}'
                            .toLowerCase()
                            .contains(_query.toLowerCase()),
                  )
                  .toList()
            : <Hadith>[];
        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.ui_hadith_intro,
                      style: context.textTheme.bodySmall?.copyWith(height: 1.7),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      textInputAction: TextInputAction.search,
                      controller: _search,
                      onChanged: (value) =>
                          setState(() => _query = value.trim()),
                      decoration: InputDecoration(
                        hintText: context.loc.ui_hadith_search,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'reset'.tr(),
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _search.clear();
                                  setState(() => _query = '');
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SakinaCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          itemHeight: null,
                          value: _selectedBook,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: context.primaryColor,
                          ),
                          style: context.textTheme.titleMedium,
                          dropdownColor: context.ramadanTheme.cardSurface,
                          items: _books.keys
                              .map(
                                (book) => DropdownMenuItem(
                                  value: book,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Text(book),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (book) {
                            if (book == null || book == _selectedBook) return;
                            setState(() {
                              _selectedBook = book;
                              _query = '';
                              _search.clear();
                            });
                            context.read<HadithCubit>().loadHadiths(
                              url: _books[book],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state is HadithLoading || state is HadithInitial)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state is HadithError)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'something_went_wrong'.tr(),
                          style: context.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: Text('retry'.tr()),
                          onPressed: () => context
                              .read<HadithCubit>()
                              .loadHadiths(url: _books[_selectedBook]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (hadiths.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 40,
                          color: context.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.loc.ui_no_results,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            if (_query.isEmpty) {
                              context.read<HadithCubit>().loadHadiths(
                                url: _books[_selectedBook],
                              );
                            } else {
                              _search.clear();
                              setState(() => _query = '');
                            }
                          },
                          icon: Icon(
                            _query.isEmpty
                                ? Icons.refresh_rounded
                                : Icons.close_rounded,
                          ),
                          label: Text(
                            (_query.isEmpty ? 'retry' : 'reset').tr(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: hadiths.length,
                  itemBuilder: (context, index) {
                    final hadith = hadiths[index];
                    final featured = index == 0 && _query.isEmpty;
                    final foreground = featured
                        ? Colors.white
                        : context.ramadanTheme.textPrimary;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: featured
                            ? SakinaColors.hero(context)
                            : context.ramadanTheme.cardSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: featured
                                ? SakinaColors.hero(context)
                                : context.ramadanTheme.borderColor,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _open(hadith),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        featured
                                            ? _selectedBook
                                            : '${'hadith_title'.tr()} ${hadith.id ?? index + 1}',
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                              color: featured
                                                  ? SakinaColors.gold(context)
                                                  : context.primaryColor,
                                            ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.format_quote_rounded,
                                      color: featured
                                          ? SakinaColors.gold(context)
                                          : context.primaryColor,
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _text(hadith),
                                  maxLines: featured ? 5 : 4,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection:
                                      (context.locale.languageCode == 'ar'
                                          ? hadith.textAr?.trim().isNotEmpty ==
                                                true
                                          : hadith.textEn?.trim().isNotEmpty !=
                                                    true &&
                                                hadith.textAr
                                                        ?.trim()
                                                        .isNotEmpty ==
                                                    true)
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  style: context.textTheme.bodyLarge?.copyWith(
                                    color: foreground,
                                    height: 1.9,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Divider(
                                  color: foreground.withValues(alpha: .12),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        hadith.source ??
                                            hadith.narrator ??
                                            _selectedBook,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: foreground.withValues(
                                                alpha: .75,
                                              ),
                                            ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      textDirection: Directionality.of(context),
                                      color: foreground,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
    ),
  );
}
