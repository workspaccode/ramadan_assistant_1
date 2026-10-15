import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/persistence/auto_sync_service.dart';
import 'package:ramadan_assistant/core/persistence/prefs_sync_endpoint.dart';
import 'package:ramadan_assistant/presentation/widgets/sakina_ui.dart';

/// Lets the user point the app at their own server; sync stays off until saved.
class SyncSettingsCard extends StatefulWidget {
  const SyncSettingsCard({
    super.key,
    required this.endpoint,
    required this.sync,
    this.onChanged,
  });
  final PrefsSyncEndpointSource endpoint;
  final AutoSyncService sync;
  final VoidCallback? onChanged;
  @override
  State<SyncSettingsCard> createState() => _SyncSettingsCardState();
}

class _SyncSettingsCardState extends State<SyncSettingsCard> {
  final _form = GlobalKey<FormState>();
  final _url = TextEditingController();
  final _token = TextEditingController();
  bool _enabled = false;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _url.dispose();
    _token.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final enabled = await widget.endpoint.current() != null;
    final url = await widget.endpoint.savedUrl();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _url.text = url;
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    await widget.endpoint.save(url: _url.text, token: _token.text);
    _token.clear();
    final enabled = await widget.endpoint.current() != null;
    if (!mounted) return;
    setState(() {
      _busy = false;
      _enabled = enabled;
      _message = context.loc.sync_saved;
    });
    widget.onChanged?.call();
    unawaited(_syncNow());
  }

  Future<void> _disable() async {
    await widget.endpoint.clear();
    if (!mounted) return;
    setState(() {
      _enabled = false;
      _url.clear();
      _message = context.loc.sync_disabled;
    });
    widget.onChanged?.call();
  }

  Future<void> _syncNow() async {
    if (!mounted) return;
    setState(() => _busy = true);
    final count = await widget.sync.syncNow();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = widget.sync.lastError == null
          ? context.loc.sync_uploaded(count)
          : context.loc.sync_failed;
    });
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    return SakinaCard(
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_sync_outlined, color: context.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.sync_title,
                    style: context.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_enabled ? loc.sync_saved : loc.sync_not_configured),
            const SizedBox(height: 8),
            Text(loc.sync_intro, style: context.textTheme.bodyMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _url,
              keyboardType: TextInputType.url,
              textDirection: TextDirection.ltr,
              autocorrect: false,
              decoration: InputDecoration(labelText: loc.sync_url_label),
              validator: (value) =>
                  (value ?? '').trim().toLowerCase().startsWith('https://')
                  ? null
                  : loc.sync_https_required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _token,
              obscureText: true,
              textDirection: TextDirection.ltr,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(labelText: loc.sync_token_label),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? loc.sync_token_required : null,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: Text(loc.sync_save),
                ),
                if (_enabled) ...[
                  OutlinedButton(
                    onPressed: _busy ? null : _syncNow,
                    child: Text(loc.sync_now),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _disable,
                    child: Text(loc.sync_disable),
                  ),
                ],
              ],
            ),
            if (_busy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (_message != null) ...[
              const SizedBox(height: 12),
              Semantics(liveRegion: true, child: Text(_message!)),
            ],
          ],
        ),
      ),
    );
  }
}
