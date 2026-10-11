import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/utils/smart_update_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateScreen extends StatefulWidget {
  final Map<String, dynamic>? updateData;

  const UpdateScreen({super.key, this.updateData});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final SmartUpdateManager _updateManager = sl<SmartUpdateManager>();

  _UpdateState _state = _UpdateState.checking;
  String? _errorMessage;

  // Language-aware update payload (title_xx / description_xx keys).
  String? _localizedTitle;
  String? _localizedDescription;
  List<dynamic>? _localizedChangelog;

  @override
  void initState() {
    super.initState();
    // If we have data, show it; otherwise, check for updates
    if (widget.updateData != null) {
      _state = _UpdateState.available;
      _localizeUpdateData();
    } else {
      _checkForUpdates();
    }
  }

  /// Picks the update title/description/changelog for the user's language,
  /// falling back to Arabic, then to any available key — instead of always
  /// showing the Arabic payload to English/Urdu users.
  Future<void> _localizeUpdateData() async {
    final data = widget.updateData;
    if (data == null) return;

    String lang = 'ar';
    try {
      final prefs = await SharedPreferences.getInstance();
      lang = prefs.getString('language_code') ?? 'ar';
    } catch (_) {}

    List<dynamic>? pickList(String base) {
      final raw = data['${base}_$lang'] ?? data['${base}_ar'] ?? data[base];
      return raw is List && raw.isNotEmpty ? raw : null;
    }

    if (mounted) {
      setState(() {
        _localizedTitle =
            data['title_$lang'] ?? data['title_ar'] ?? data['title'];
        _localizedDescription =
            data['description_$lang'] ??
            data['description_ar'] ??
            data['description'];
        _localizedChangelog = pickList('changelog') ?? pickList('features');
      });
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() => _state = _UpdateState.checking);
    try {
      final status = await _updateManager.getCurrentUpdateStatus();
      setState(() {
        _state = status.isUpdateAvailable
            ? _UpdateState.available
            : _UpdateState.upToDate;
      });
    } catch (e) {
      setState(() {
        _state = _UpdateState.error;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _performUpdate() async {
    setState(() => _state = _UpdateState.downloading);
    try {
      await _updateManager.checkManualUpdates(context);
      setState(() => _state = _UpdateState.completed);
    } catch (e) {
      setState(() {
        _state = _UpdateState.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: theme.primary.withValues(alpha: 0.9),
            border: null,
            largeTitle: Text(
              'update_screen_title'.tr(),
              style: TextStyle(
                color: context.isDark
                    ? CupertinoColors.white
                    : CupertinoColors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_state) {
      case _UpdateState.checking:
        return _buildCheckingState(context);
      case _UpdateState.available:
        return _buildAvailableState(context);
      case _UpdateState.downloading:
        return _buildDownloadingState(context);
      case _UpdateState.completed:
        return _buildCompletedState(context);
      case _UpdateState.upToDate:
        return _buildUpToDateState(context);
      case _UpdateState.error:
        return _buildErrorState(context);
    }
  }

  Widget _buildCheckingState(BuildContext context) {
    final theme = context.ramadanTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(radius: 20),
          const SizedBox(height: 24),
          Text(
            'checking_updates'.tr(),
            style: TextStyle(color: theme.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableState(BuildContext context) {
    final theme = context.ramadanTheme;
    final data = widget.updateData;

    final title = _localizedTitle ?? 'new_update'.tr();
    final description = _localizedDescription ?? 'update_available_desc'.tr();
    final changelog = _localizedChangelog;
    final size = data?['size_in_mb'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Update icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.system_update_rounded,
            size: 64,
            color: theme.primary,
          ),
        ),
        const SizedBox(height: 32),

        // Title
        Text(
          title,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          description,
          style: TextStyle(color: theme.textSecondary, fontSize: 16),
          textAlign: TextAlign.center,
        ),

        // Changelog
        if (changelog != null && changelog.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.borderColor.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'new_features'.tr(),
                  style: TextStyle(
                    color: theme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...changelog.map<Widget>(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: theme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Size
        if (size != null) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download, size: 16, color: theme.textDim),
              const SizedBox(width: 6),
              Text(
                '${'size_label'.tr()}: $size MB',
                style: TextStyle(color: theme.textDim, fontSize: 13),
              ),
            ],
          ),
        ],

        const SizedBox(height: 32),

        // Update button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _performUpdate,
            icon: const Icon(Icons.download_rounded),
            label: Text(
              'update_now_btn'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: theme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadingState(BuildContext context) {
    final theme = context.ramadanTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              color: theme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'downloading_update'.tr(),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'dont_close_app'.tr(),
            style: TextStyle(color: theme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    final theme = context.ramadanTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'update_completed'.tr(),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'restart_to_apply'.tr(),
            style: TextStyle(color: theme.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text('back'.tr(), style: const TextStyle(fontSize: 18)),
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpToDateState(BuildContext context) {
    final theme = context.ramadanTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 64,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'up_to_date_title'.tr(),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'no_updates_available'.tr(),
            style: TextStyle(color: theme.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: _checkForUpdates,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('search_again'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = context.ramadanTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'error_occurred'.tr(),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: theme.textDim, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: _checkForUpdates,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('retry'.tr()),
          ),
        ],
      ),
    );
  }
}

enum _UpdateState {
  checking,
  available,
  downloading,
  completed,
  upToDate,
  error,
}
