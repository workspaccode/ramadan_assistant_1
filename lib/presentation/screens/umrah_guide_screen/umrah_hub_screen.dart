import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/umrah_storage_service.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/data/models/umrah_trip_model.dart';
import 'package:ramadan_assistant/presentation/screens/umrah_guide_screen/umrah_guide_screen.dart';

class UmrahHubScreen extends StatefulWidget {
  const UmrahHubScreen({super.key});

  @override
  State<UmrahHubScreen> createState() => _UmrahHubScreenState();
}

class _UmrahHubScreenState extends State<UmrahHubScreen> {
  UmrahStorageService? _storageService;
  List<UmrahTrip> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storageService = await UmrahStorageService.getInstance();
    _loadHistory();
  }

  void _loadHistory() {
    if (_storageService == null) return;
    setState(() {
      _history = _storageService!.getUmrahHistory();
      _isLoading = false;
    });
  }

  Future<void> _startNewUmrah() async {
    final theme = context.ramadanTheme;
    final now = DateTime.now();

    // 1. Pick Date
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'umrah_date_picker_help'.tr(),
      cancelText: 'cancel'.tr(),
      confirmText: 'next'.tr(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: theme.primary,
            onPrimary: Colors.white,
            surface: theme.cardSurface,
            onSurface: theme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (date == null || !mounted) return;

    // 2. Pick Time
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
      helpText: 'umrah_time_picker_help'.tr(),
      cancelText: 'back'.tr(),
      confirmText: 'start_trip'.tr(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: theme.primary,
            onPrimary: Colors.white,
            surface: theme.cardSurface,
            onSurface: theme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (time == null || !mounted) return;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    await _storageService?.startNewTrip(selectedDateTime);
    if (!mounted) return;

    // Clear the DB progress for the new trip
    final db = context.read<AppDatabase>();
    await db.delete(db.umrahProgress).go();

    _loadHistory();

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UmrahGuideScreen()),
    ).then((_) => _loadHistory()); // Reload history when returning
  }

  void _continueUmrah() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UmrahGuideScreen()),
    ).then((_) => _loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = context.ramadanTheme;
    final activeTrip = _storageService?.getActiveTrip();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'umrah_and_hajj_rites'.tr(),
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.textPrimary),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'main_services'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Umrah Card
                  _buildActionCard(
                    context,
                    title: 'umrah'.tr(),
                    subtitle: activeTrip != null
                        ? 'umrah_in_progress'.tr()
                        : 'start_new_umrah'.tr(),
                    icon: Icons.mosque_rounded,
                    color: theme.primary,
                    isActive: activeTrip != null,
                    onTap: activeTrip != null ? _continueUmrah : _startNewUmrah,
                  ),

                  const SizedBox(height: 12),

                  // Hajj Card
                  _buildLockedCard(
                    context,
                    title: 'hajj'.tr(),
                    subtitle: 'coming_soon'.tr(),
                    icon: Icons.groups_rounded,
                  ),

                  const SizedBox(height: 12),

                  // Madinah Card
                  _buildLockedCard(
                    context,
                    title: 'visiting_madinah'.tr(),
                    subtitle: 'coming_soon'.tr(),
                    icon: Icons.location_city_rounded,
                  ),

                  const SizedBox(height: 32),

                  if (_history.isNotEmpty) ...[
                    Text(
                      'trip_history'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._history.map((trip) => _buildHistoryCard(context, trip)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = context.ramadanTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? color.withOpacity(0.5)
                : theme.textDim.withOpacity(0.1),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isActive ? color : theme.textSecondary,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: theme.textDim,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = context.ramadanTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardSurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.textDim.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.textDim.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.textDim, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textDim,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.lock_rounded, size: 14, color: theme.textDim),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: theme.textDim),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, UmrahTrip trip) {
    final theme = context.ramadanTheme;
    final isCompleted = trip.status == 'completed';
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'en');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.textDim.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCompleted
                  ? theme.success.withOpacity(0.1)
                  : theme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.timelapse_rounded,
              color: isCompleted ? theme.success : theme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'umrah_trip'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'start_prefix'.tr(args: [dateFormat.format(trip.startDate)]),
                  style: TextStyle(fontSize: 13, color: theme.textSecondary),
                ),
                if (trip.endDate != null)
                  Text(
                    'end_prefix'.tr(args: [dateFormat.format(trip.endDate!)]),
                    style: TextStyle(fontSize: 13, color: theme.textSecondary),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? theme.success.withOpacity(0.1)
                  : theme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isCompleted ? 'completed'.tr() : 'ongoing'.tr(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isCompleted ? theme.success : theme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
