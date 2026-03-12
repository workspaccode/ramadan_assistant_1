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
    'instant_update',
    'manual_update',
    'maintenance',
    'greeting',
    'exclusive',
    'adhan',
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
      backgroundColor: theme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: theme.primary.withValues(alpha: 0.9),
            border: null,
            largeTitle: Text(
              'notifications_title'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
            trailing: _history.isNotEmpty
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showClearConfirmation(context),
                    child: const Icon(
                      CupertinoIcons.trash,
                      color: Colors.white,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? theme.primary : theme.cardSurface,
                borderRadius: BorderRadius.circular(25),
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
                          offset: const Offset(0, 4),
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
                    fontSize: 13,
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: theme.primary.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'no_notifications'.tr(),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'no_notifications_desc'.tr(),
              style: TextStyle(color: theme.textDim, fontSize: 14),
              textAlign: TextAlign.center,
            ),
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
    final track = item['track'] ?? 'instant_update';
    final category = item['category'] ?? 'general';
    final status = item['status'] ?? 'applied';
    final title = item['title'] ?? 'إشعار جديد';
    final body = item['body'] ?? '';
    final timestamp = item['timestamp'] != null
        ? DateTime.tryParse(item['timestamp'])
        : null;

    final isManual = type == 'update' && track == 'manual_update';
    final isPending = status == 'pending';

    Color categoryColor;
    IconData categoryIcon;

    switch (category) {
      case 'instant_update':
        categoryColor = const Color(0xFF00BFA5);
        categoryIcon = Icons.bolt_rounded;
        break;
      case 'manual_update':
        categoryColor = const Color(0xFFFF9100);
        categoryIcon = Icons.storefront_rounded;
        break;
      case 'maintenance':
        categoryColor = const Color(0xFFFF5252);
        categoryIcon = Icons.settings_suggest_rounded;
        break;
      case 'greeting':
        categoryColor = const Color(0xFFE040FB);
        categoryIcon = Icons.auto_awesome_rounded;
        break;
      case 'exclusive':
        categoryColor = const Color(0xFFFFD600);
        categoryIcon = Icons.star_rounded;
        break;
      case 'adhan':
        categoryColor = theme.primary;
        categoryIcon = Icons.mosque_rounded;
        break;
      default:
        categoryColor = const Color(0xFF448AFF);
        categoryIcon = Icons.notifications_active_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left color accent
              Container(width: 6, color: categoryColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                categoryIcon,
                                size: 16,
                                color: categoryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'category_$category'.tr(),
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          if (timestamp != null)
                            Text(
                              _formatTime(timestamp),
                              style: TextStyle(
                                color: theme.textDim,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        style: TextStyle(
                          color: theme.textSecondary.withValues(alpha: 0.9),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isManual && isPending) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
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
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'تحديث الآن',
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: categoryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
    if (diff.inMinutes < 1) return 'now'.tr();
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${'minutes'.tr()}';
    if (diff.inHours < 24) return '${diff.inHours} ${'hour'.tr()}';
    return '${time.day}/${time.month}/${time.year}';
  }

  void _showClearConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text('reset'.tr()),
        content: const Text('هل تريد مسح سجل الإشعارات بالكامل؟'),
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
            child: const Text('مسح السجل'),
          ),
        ],
      ),
    );
  }
}
