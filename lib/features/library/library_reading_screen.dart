import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';
import 'library_cubit.dart';
import 'library_models.dart';
import 'library_playback.dart';
import 'library_screen.dart' show libraryMediaLabel;

class LibraryReadingScreen extends StatefulWidget {
  const LibraryReadingScreen({
    super.key,
    required this.itemId,
    this.mediaEngine,
  });
  final String itemId;
  final LibraryMediaEngine? mediaEngine;
  @override
  State<LibraryReadingScreen> createState() => _LibraryReadingScreenState();
}

class _LibraryReadingScreenState extends State<LibraryReadingScreen>
    with WidgetsBindingObserver {
  late final LibraryPlaybackCubit _playback = LibraryPlaybackCubit(
    widget.mediaEngine ?? DeviceLibraryMediaEngine(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(_playback.stop());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_playback.close());
    super.dispose();
  }

  Future<void> _openLink(Uri uri) async {
    await _playback.stop();
    if (!mounted) return;
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw StateError('Link unavailable');
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.library_playback_failed)),
      );
    }
  }

  Future<void> _addMedia() async {
    await _playback.stop();
    if (!mounted) return;
    final cubit = context.read<LibraryCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _AddMediaSheet(itemId: widget.itemId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<LibraryCubit, LibraryState>(
    builder: (context, state) {
      final matches = state.items.where((item) => item.id == widget.itemId);
      if (matches.isEmpty) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(child: Text(context.loc.ui_no_results)),
        );
      }
      final item = matches.first;
      final locale = context.locale.languageCode;
      return Scaffold(
        appBar: AppBar(
          title: Text(item.title(locale)),
          actions: [
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
                  : () => context.read<LibraryCubit>().setFavorite(
                      item.id,
                      !item.favorite,
                    ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: BlocBuilder<LibraryPlaybackCubit, LibraryPlaybackState>(
              bloc: _playback,
              builder: (context, playback) => FilledButton.icon(
                onPressed: playback.busy
                    ? null
                    : () => playback.active
                          ? _playback.stop()
                          : _playback.speak(item.text(locale), switch (locale) {
                              'ar' => 'ar-SA',
                              'ur' => 'ur-PK',
                              _ => 'en-US',
                            }),
                icon: Icon(
                  playback.active
                      ? Icons.stop_rounded
                      : Icons.record_voice_over_rounded,
                ),
                label: Text(
                  playback.active
                      ? context.loc.library_stop
                      : context.loc.library_read_aloud,
                  textAlign: TextAlign.center,
                ),
                style: FilledButton.styleFrom(minimumSize: const Size(48, 56)),
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              context.loc.library_summary_note,
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            SakinaCard(
              child: SelectableText(
                item.text(locale),
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  height: 1.8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(item.source, style: context.textTheme.bodySmall),
            TextButton.icon(
              onPressed: () => _openLink(item.sourceUrl),
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(context.loc.library_source),
            ),
            if (state.saveFailed)
              Semantics(
                liveRegion: true,
                child: Text(
                  context.loc.library_save_failed,
                  style: TextStyle(color: context.errorColor),
                ),
              ),
            BlocBuilder<LibraryPlaybackCubit, LibraryPlaybackState>(
              bloc: _playback,
              builder: (context, playback) => playback.failed
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          context.loc.library_playback_failed,
                          style: TextStyle(color: context.errorColor),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            SakinaSectionTitle(
              context.loc.library_media,
              icon: Icons.perm_media_outlined,
            ),
            const SizedBox(height: 12),
            if (item.media.isEmpty)
              SakinaCard(child: Text(context.loc.library_no_media)),
            for (final media in item.media)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SakinaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        media.label.isEmpty
                            ? libraryMediaLabel(context, media.kind)
                            : media.label,
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.loc.library_user_media,
                        style: context.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      if (media.kind == LibraryMediaKind.image)
                        _LibraryNetworkImage(media: media),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (media.kind != LibraryMediaKind.image)
                            OutlinedButton.icon(
                              onPressed: () =>
                                  media.kind == LibraryMediaKind.audio
                                  ? _playback.play(media.url)
                                  : _openLink(media.url),
                              icon: Icon(
                                media.kind == LibraryMediaKind.audio
                                    ? Icons.play_arrow_rounded
                                    : Icons.open_in_new_rounded,
                              ),
                              label: Text(
                                libraryMediaLabel(context, media.kind),
                              ),
                            ),
                          TextButton.icon(
                            onPressed: state.saving
                                ? null
                                : () => context
                                      .read<LibraryCubit>()
                                      .removeMedia(item.id, media.id),
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: Text(context.loc.library_remove_media),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addMedia,
              icon: const Icon(Icons.add_link_rounded),
              label: Text(context.loc.library_add_media),
            ),
          ],
        ),
      );
    },
  );
}

class _LibraryNetworkImage extends StatefulWidget {
  const _LibraryNetworkImage({required this.media});
  final LibraryMedia media;
  @override
  State<_LibraryNetworkImage> createState() => _LibraryNetworkImageState();
}

class _LibraryNetworkImageState extends State<_LibraryNetworkImage> {
  int _attempt = 0;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: AspectRatio(
      aspectRatio: 1.5,
      child: Image.network(
        widget.media.url.toString(),
        key: ValueKey(_attempt),
        fit: BoxFit.contain,
        semanticLabel: widget.media.label.isEmpty
            ? context.loc.library_image
            : widget.media.label,
        loadingBuilder: (context, image, progress) => progress == null
            ? image
            : const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error, stack) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image_outlined),
            Flexible(
              child: Text(
                context.loc.library_playback_failed,
                textAlign: TextAlign.center,
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _attempt++),
              icon: const Icon(Icons.refresh_rounded),
              label: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AddMediaSheet extends StatefulWidget {
  const _AddMediaSheet({required this.itemId});
  final String itemId;
  @override
  State<_AddMediaSheet> createState() => _AddMediaSheetState();
}

class _AddMediaSheetState extends State<_AddMediaSheet> {
  final _url = TextEditingController();
  final _label = TextEditingController();
  LibraryMediaKind _kind = LibraryMediaKind.audio;
  bool _invalid = false, _saving = false, _failed = false;
  @override
  void dispose() {
    _url.dispose();
    _label.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (libraryHttpsUri(_url.text) == null) {
      setState(() => _invalid = true);
      return;
    }
    setState(() {
      _saving = true;
      _invalid = false;
      _failed = false;
    });
    final success = await context.read<LibraryCubit>().addMedia(
      widget.itemId,
      _kind,
      _url.text,
      _label.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.loc.library_add_media,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kind in LibraryMediaKind.values)
                  ChoiceChip(
                    label: Text(libraryMediaLabel(context, kind)),
                    labelStyle: context.textTheme.labelMedium?.copyWith(
                      color: _kind == kind
                          ? context.onPrimaryColor
                          : context.primaryColor,
                    ),
                    selected: _kind == kind,
                    onSelected: _saving
                        ? null
                        : (_) => setState(() => _kind = kind),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _url,
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr,
              autocorrect: false,
              enabled: !_saving,
              decoration: InputDecoration(
                labelText: context.loc.library_link,
                errorText: _invalid ? context.loc.library_invalid_link : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _label,
              enabled: !_saving,
              decoration: InputDecoration(
                labelText: context.loc.library_link_label,
              ),
            ),
            const SizedBox(height: 12),
            if (_failed)
              Text(
                context.loc.library_save_failed,
                style: TextStyle(color: context.errorColor),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(context.loc.library_save),
              style: FilledButton.styleFrom(minimumSize: const Size(48, 56)),
            ),
            TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
          ],
        ),
      ),
    ),
  );
}
