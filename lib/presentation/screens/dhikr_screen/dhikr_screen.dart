import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/data/models/dhikr_presets.dart';
import 'package:ramadan_assistant/presentation/screens/reminders_screen/reminders_screen.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});
  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  static const _storageKey = 'dhikr_library_counts';
  final Map<String, int> _counts = {};
  SharedPreferences? _preferences;
  String? _category;
  String? _playing;
  AudioPlayer? _player;
  StreamSubscription<void>? _completion;
  final TextEditingController _search = TextEditingController();
  String _query = '';
  bool _countsUnavailable = false;
  bool _audioBusy = false;
  int _audioRequest = 0;
  Future<void> _saveCounts = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _loadCounts();
    AppTabNavigation.index.addListener(_onTabChanged);
  }

  Future<void> _loadCounts() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(_storageKey);
      Map<String, int> counts = {};
      if (saved != null) {
        try {
          final value = jsonDecode(saved);
          if (value is Map) {
            counts = {
              for (final entry in value.entries)
                if (entry.key is String &&
                    entry.value is int &&
                    entry.value >= 0)
                  entry.key as String: entry.value as int,
            };
          }
        } on FormatException {
          /* Keep a readable library if stored data is invalid. */
        }
      }
      if (!mounted) return;
      setState(() {
        _preferences = preferences;
        _counts.addAll(counts);
        _countsUnavailable = false;
      });
    } catch (_) {
      if (mounted) setState(() => _countsUnavailable = true);
    }
  }

  void _onTabChanged() {
    if (AppTabNavigation.index.value != 3 && (_playing != null || _audioBusy)) {
      _audioRequest++;
      unawaited(_stopAudio());
      if (mounted) setState(() => _playing = null);
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _player?.stop();
    } catch (_) {
      // Leaving the library must remain safe if an audio plugin has failed.
    }
  }

  Future<void> _play(Map<String, String> dhikr) async {
    if (_audioBusy) return;
    final request = ++_audioRequest;
    setState(() => _audioBusy = true);
    final id = dhikr['id']!;
    try {
      if (_playing == id) {
        await _player?.stop();
        if (mounted) setState(() => _playing = null);
        return;
      }
      if (_player == null) {
        _player = AudioPlayer();
        _completion = _player!.onPlayerComplete.listen((_) {
          if (mounted) setState(() => _playing = null);
        });
      }
      await _player!.play(AssetSource('audio/${dhikr['audioFile']}'));
      if (!mounted || request != _audioRequest) {
        await _stopAudio();
        return;
      }
      if (mounted) setState(() => _playing = id);
    } catch (_) {
      if (!mounted || request != _audioRequest) return;
      setState(() => _playing = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('something_went_wrong'.tr())));
    } finally {
      if (mounted) setState(() => _audioBusy = false);
    }
  }

  void _count(String id) {
    final preferences = _preferences;
    if (preferences == null) return;
    setState(() => _counts[id] = (_counts[id] ?? 0) + 1);
    final saved = jsonEncode(_counts);
    _saveCounts = _saveCounts.then((_) async {
      try {
        final success = await preferences.setString(_storageKey, saved);
        if (!success) throw StateError('Dhikr count was not saved');
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('something_went_wrong'.tr())));
      }
    });
  }

  String _categoryName(String category) => switch (category) {
    'Tasbih' => context.loc.ui_tasbih_category,
    'Salawat' => context.loc.ui_salawat_category,
    'Tawheed' => context.loc.ui_tawheed_category,
    'Istighfar' => context.loc.ui_istighfar_category,
    _ => context.loc.ui_dua_category,
  };

  @override
  void dispose() {
    _audioRequest++;
    _search.dispose();
    AppTabNavigation.index.removeListener(_onTabChanged);
    unawaited(_releaseAudio());
    super.dispose();
  }

  Future<void> _releaseAudio() async {
    try {
      await _completion?.cancel();
      await _player?.dispose();
    } catch (_) {
      // Plugin teardown must not surface an unhandled asynchronous exception.
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = DhikrPresets.dhikrList
        .map((d) => d['category'] ?? 'Dua')
        .toSet()
        .toList();
    final dhikrs = DhikrPresets.dhikrList
        .where(
          (d) =>
              (_category == null || d['category'] == _category) &&
              (_query.isEmpty ||
                  [
                    d['arabic'],
                    d['translation'],
                    d['urdu'],
                    d['transliteration'],
                    _categoryName(d['category'] ?? 'Dua'),
                  ].join(' ').toLowerCase().contains(_query.toLowerCase())),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.ui_adhkar_library),
        automaticallyImplyLeading: !AppShellScope.contains(context),
        actions: [
          IconButton(
            tooltip: 'reminders_title'.tr(),
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RemindersScreen()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SakinaBottomBar(selectedIndex: 3),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: dhikrs.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _search,
                  onChanged: (value) => setState(() => _query = value.trim()),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'search_hint'.tr(),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'reset'.tr(),
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height:
                      48 + (MediaQuery.textScalerOf(context).scale(16) - 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Text(context.loc.ui_all),
                          labelStyle: context.textTheme.labelMedium?.copyWith(
                            color: _category == null
                                ? context.onPrimaryColor
                                : context.primaryColor,
                          ),
                          selected: _category == null,
                          onSelected: (_) => setState(() => _category = null),
                        ),
                      ),
                      ...categories.map(
                        (category) => Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: ChoiceChip(
                            label: Text(_categoryName(category)),
                            labelStyle: context.textTheme.labelMedium?.copyWith(
                              color: _category == category
                                  ? context.onPrimaryColor
                                  : context.primaryColor,
                            ),
                            selected: _category == category,
                            onSelected: (_) =>
                                setState(() => _category = category),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${dhikrs.length} ${context.loc.ui_saved_dhikr}',
                  style: context.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                if (_countsUnavailable) ...[
                  SakinaCard(
                    child: Column(
                      children: [
                        Text('something_went_wrong'.tr()),
                        TextButton.icon(
                          onPressed: _loadCounts,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text('retry'.tr()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (dhikrs.isEmpty)
                  SakinaCard(
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          context.loc.ui_no_results,
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () {
                            _search.clear();
                            setState(() {
                              _query = '';
                              _category = null;
                            });
                          },
                          child: Text('reset'.tr()),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }
          final dhikr = dhikrs[index - 1];
          final id = dhikr['id']!;
          final text = DhikrPresets.getTranslation(
            dhikr,
            context.locale.languageCode,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SakinaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: context.ramadanTheme.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _categoryName(dhikr['category'] ?? 'Dua'),
                          style: context.textTheme.titleSmall,
                        ),
                      ),
                      SakinaBadge(
                        '${_counts[id] ?? 0}',
                        gold: true,
                        icon: Icons.check_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      height: 1.9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: context.ramadanTheme.borderColor),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: _preferences == null
                            ? null
                            : () => _count(id),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text('${'times'.tr()} ${_counts[id] ?? 0}'),
                      ),
                      IconButton(
                        tooltip: context.loc.ui_copy,
                        icon: const Icon(Icons.copy_outlined, size: 20),
                        onPressed: () async {
                          try {
                            await Clipboard.setData(ClipboardData(text: text));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(context.loc.ui_copied)),
                              );
                            }
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('something_went_wrong'.tr()),
                              ),
                            );
                          }
                        },
                      ),
                      if (dhikr['audioFile']?.isNotEmpty == true)
                        IconButton(
                          tooltip: _playing == id
                              ? context.loc.ui_listen_stop
                              : context.loc.ui_speak,
                          icon: Icon(
                            _playing == id
                                ? Icons.stop_circle_outlined
                                : Icons.volume_up_outlined,
                            size: 22,
                          ),
                          onPressed: _audioBusy ? null : () => _play(dhikr),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
