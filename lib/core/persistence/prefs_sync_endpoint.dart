import 'package:ramadan_assistant/core/persistence/http_sync_gateway.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sync stays off until both values are stored; nothing is uploaded otherwise.
class PrefsSyncEndpointSource implements SyncEndpointSource {
  static const urlKey = 'sync_endpoint_url';
  static const tokenKey = 'sync_token';

  @override
  Future<SyncEndpoint?> current() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(urlKey)?.trim();
    final token = prefs.getString(tokenKey)?.trim();
    if (url == null || url.isEmpty || token == null || token.isEmpty) {
      return null;
    }
    // Personal data must never travel over plain HTTP.
    if (!url.toLowerCase().startsWith('https://')) return null;
    return SyncEndpoint(
      baseUrl: url.replaceAll(RegExp(r'/+$'), ''),
      token: token,
    );
  }

  /// Stored values are validated again in [current]; callers validate for UX.
  Future<void> save({required String url, required String token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(urlKey, url.trim());
    await prefs.setString(tokenKey, token.trim());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(urlKey);
    await prefs.remove(tokenKey);
  }

  /// Raw saved URL for editing; the token is never shown back.
  Future<String> savedUrl() async =>
      (await SharedPreferences.getInstance()).getString(urlKey) ?? '';
}
