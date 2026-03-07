import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/preferences_service.dart';
import 'package:ramadan_assistant/presentation/screens/update_screen/update_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  final List<String> _categories = [
    'all',
    'auto_update',
    'manual_update',
    'maintenance',
    'greeting',
    'exclusive',
    'general',
  ];

  List<Map<String, dynamic>> get _filteredHistory {
    if (_selectedCategory == 'all') return _history;
    return _history
        .where((item) => (item['category'] ?? 'general') == _selectedCategory)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await PreferencesService.getInstance();
    final history = prefs.getUpdateHistory();
    setState(() {
      _history = history.reversed.toList(); // newest first
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    final prefs = await PreferencesService.getInstance();
    await prefs.clearUpdateHistory();
    setState(() => _history = []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ramadanTheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: theme.primary.withValues(alpha: 0.9),
            border: null,
            largeTitle: Text('notifications_title'.tr()),
            trailing: _history.isNotEmpty
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showClearConfirmation(context),
                    child: const Icon(
                      CupertinoIcons.trash,
                      // color: CupertinoColors.white,
                      size: 20,
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(child: _buildCategoryFilters()),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator()),
            )
          else if (_filteredHistory.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(context))
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildNotificationCard(
                    context,
                    _filteredHistory[index],
                    index,
                  ),
                  childCount: _filteredHistory.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final theme = context.ramadanTheme;
    return SizedBox(
      height: 55,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? theme.primary : theme.cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? theme.primary
                      : theme.borderColor.withValues(alpha: 0.2),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  'category_$category'.tr(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = context.ramadanTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: theme.textDim,
          ),
          const SizedBox(height: 16),
          Text(
            'no_notifications'.tr(),
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'no_notifications_desc'.tr(),
            style: TextStyle(color: theme.textDim, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  ) {
    final theme = context.ramadanTheme;
    final type = item['type'] ?? 'general';
    final track = item['track'] ?? 'auto-update';
    final category = item['category'] ?? 'general';

    final status = item['status'] ?? 'applied';
    final title = item['title'] ?? 'إشعار جديد';
    final body = item['body'] ?? '';
    final timestamp = item['timestamp'] != null
        ? DateTime.tryParse(item['timestamp'])
        : null;

    final isManual = type == 'update' && track == 'manual-update';
    final isPending = status == 'pending';

    Color categoryColor;
    IconData categoryIcon;

    switch (category) {
      case 'auto_update':
        categoryColor = Colors.teal;
        categoryIcon = Icons.autorenew_rounded;
        break;
      case 'manual_update':
        categoryColor = Colors.orange;
        categoryIcon = Icons.shop;
        break;
      case 'maintenance':
        categoryColor = Colors.redAccent;
        categoryIcon = Icons.build_circle;
        break;
      case 'greeting':
        categoryColor = Colors.purple;
        categoryIcon = Icons.celebration;
        break;
      case 'exclusive':
        categoryColor = Colors.amber.shade700;
        categoryIcon = Icons.workspace_premium;
        break;
      default:
        categoryColor = Colors.blue;
        categoryIcon = Icons.notifications;
    }

    final statusColor = isPending ? Colors.orange : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isManual && isPending
            ? () {
                final data = item['data'];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UpdateScreen(
                      updateData: data is Map
                          ? Map<String, dynamic>.from(data)
                          : null,
                    ),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPending
                  ? theme.warning.withValues(alpha: 0.3)
                  : theme.borderColor.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: category badge + time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(categoryIcon, size: 14, color: categoryColor),
                        const SizedBox(width: 4),
                        Text(
                          'category_$category'.tr(),
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge (Only for updates)
                  if (type == 'update')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPending ? 'في الانتظار' : 'تم التطبيق',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                title,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (body.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(color: theme.textSecondary, fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 10),

              // Footer: time + action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (timestamp != null)
                    Text(
                      _formatTime(timestamp),
                      style: TextStyle(color: theme.textDim, fontSize: 12),
                    ),
                  if (isManual && isPending)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'اضغط للتحديث',
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: categoryColor,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${time.day}/${time.month}/${time.year}';
  }

  void _showClearConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('مسح السجل'),
        content: const Text('هل تريد مسح جميع الإشعارات؟'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr()),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              _clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }
}
