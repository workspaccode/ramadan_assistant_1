import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/di/service_locator.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/utils/smart_update_manager.dart';

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

  @override
  void initState() {
    super.initState();
    // If we have data, show it; otherwise, check for updates
    if (widget.updateData != null) {
      _state = _UpdateState.available;
    } else {
      _checkForUpdates();
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
              'تحديث التطبيق',
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
            'جاري البحث عن تحديثات...',
            style: TextStyle(color: theme.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableState(BuildContext context) {
    final theme = context.ramadanTheme;
    final data = widget.updateData;

    final title = data?['title_ar'] ?? 'تحديث جديد متاح';
    final description = data?['description_ar'] ?? 'يتوفر تحديث جديد للتطبيق';
    final changelog = data?['changelog_ar'];
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
        if (changelog != null && changelog is List && changelog.isNotEmpty) ...[
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
                  'ما الجديد:',
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
                'الحجم: $size MB',
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
            label: const Text(
              'تحديث الآن',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            'جاري تحميل التحديث...',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يرجى عدم إغلاق التطبيق',
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
            'تم التحديث بنجاح! 🎉',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'أعد تشغيل التطبيق لتطبيق التغييرات',
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
              label: const Text('رجوع', style: TextStyle(fontSize: 18)),
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
            'أنت تستخدم أحدث إصدار ✅',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد تحديثات متاحة حالياً',
            style: TextStyle(color: theme.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: _checkForUpdates,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة البحث'),
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
            'حدث خطأ',
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
            label: const Text('إعادة المحاولة'),
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
