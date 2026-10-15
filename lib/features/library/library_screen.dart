import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';
import 'library_cubit.dart';
import 'library_models.dart';
import 'library_reading_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _search = TextEditingController();
  String _query = '';
  LibraryKind? _kind;
  LibraryMediaKind? _mediaKind;
  bool _favorites = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reset() {
    _search.clear();
    setState(() {
      _query = '';
      _kind = null;
      _mediaKind = null;
      _favorites = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.loc.library_title)),
    body: BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        final locale = context.locale.languageCode;
        final items = state.items
            .where(
              (item) =>
                  (_kind == null || item.kind == _kind) &&
                  (!_favorites || item.favorite) &&
                  (_mediaKind == null ||
                      item.media.any((media) => media.kind == _mediaKind)) &&
                  (_query.isEmpty ||
                      '${item.title(locale)} ${item.text(locale)} ${item.source}'
                          .toLowerCase()
                          .contains(_query.toLowerCase())),
            )
            .toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Text(
              context.loc.library_intro,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: context.loc.library_search,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'reset'.tr(),
                        icon: const Icon(Icons.close_rounded),
                        onPressed: _reset,
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(context.loc.ui_all),
                  labelStyle: _chipStyle(context, _kind == null),
                  selected: _kind == null,
                  onSelected: (_) => setState(() => _kind = null),
                ),
                ChoiceChip(
                  label: Text(context.loc.library_companions),
                  labelStyle: _chipStyle(
                    context,
                    _kind == LibraryKind.companion,
                  ),
                  selected: _kind == LibraryKind.companion,
                  onSelected: (_) =>
                      setState(() => _kind = LibraryKind.companion),
                ),
                ChoiceChip(
                  label: Text(context.loc.library_short_hadith),
                  labelStyle: _chipStyle(context, _kind == LibraryKind.hadith),
                  selected: _kind == LibraryKind.hadith,
                  onSelected: (_) => setState(() => _kind = LibraryKind.hadith),
                ),
                FilterChip(
                  label: Text(context.loc.library_favorites),
                  labelStyle: _chipStyle(context, _favorites),
                  avatar: const Icon(Icons.favorite_border_rounded, size: 18),
                  selected: _favorites,
                  onSelected: (value) => setState(() => _favorites = value),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kind in LibraryMediaKind.values)
                  FilterChip(
                    label: Text(libraryMediaLabel(context, kind)),
                    labelStyle: _chipStyle(context, _mediaKind == kind),
                    selected: _mediaKind == kind,
                    onSelected: (value) =>
                        setState(() => _mediaKind = value ? kind : null),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 4),
            if (state.loading) const LinearProgressIndicator(),
            if (state.loadFailed)
              SakinaCard(
                child: Column(
                  children: [
                    Text(
                      'something_went_wrong'.tr(),
                      textAlign: TextAlign.center,
                    ),
                    TextButton.icon(
                      onPressed: context.read<LibraryCubit>().load,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text('retry'.tr()),
                    ),
                  ],
                ),
              ),
            if (state.saveFailed)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  context.loc.library_save_failed,
                  style: TextStyle(color: context.errorColor),
                ),
              ),
            if (!state.loading && !state.loadFailed && items.isEmpty)
              SakinaCard(
                child: Column(
                  children: [
                    Icon(
                      _favorites
                          ? Icons.favorite_border_rounded
                          : Icons.search_off_rounded,
                      size: 40,
                      color: context.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _favorites
                          ? context.loc.library_no_favorites
                          : context.loc.ui_no_results,
                      textAlign: TextAlign.center,
                    ),
                    TextButton(onPressed: _reset, child: Text('reset'.tr())),
                  ],
                ),
              ),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: context.ramadanTheme.cardSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: context.ramadanTheme.borderColor),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      final cubit = context.read<LibraryCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: LibraryReadingScreen(itemId: item.id),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title(locale),
                                  style: context.textTheme.titleLarge,
                                ),
                              ),
                              IconButton(
                                tooltip: item.favorite
                                    ? context.loc.library_favorite_remove
                                    : context.loc.library_favorite_add,
                                icon: Icon(
                                  item.favorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                ),
                                onPressed: state.saving
                                    ? null
                                    : () => context
                                          .read<LibraryCubit>()
                                          .setFavorite(item.id, !item.favorite),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.text(locale),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyMedium?.copyWith(
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(item.source, style: context.textTheme.bodySmall),
                          if (item.media.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: item.media
                                  .map(
                                    (media) => SakinaBadge(
                                      libraryMediaLabel(context, media.kind),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

String libraryMediaLabel(BuildContext context, LibraryMediaKind kind) =>
    switch (kind) {
      LibraryMediaKind.audio => context.loc.library_audio,
      LibraryMediaKind.video => context.loc.library_video,
      LibraryMediaKind.image => context.loc.library_image,
    };

TextStyle? _chipStyle(BuildContext context, bool selected) => context
    .textTheme
    .labelMedium
    ?.copyWith(color: selected ? context.onPrimaryColor : context.primaryColor);
