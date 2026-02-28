import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ramadan_assistant/core/constants/umrah_duas.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/core/services/location_service.dart';
import 'package:ramadan_assistant/core/services/umrah_storage_service.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_event.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_state.dart';
import 'package:ramadan_assistant/presentation/widgets/dua_widget.dart';
import 'package:vibration/vibration.dart';

class UmrahGuideView extends StatefulWidget {
  const UmrahGuideView({super.key});

  @override
  State<UmrahGuideView> createState() => _UmrahGuideViewState();
}

enum _SaiZone { safa, marwa, none }

class _UmrahGuideViewState extends State<UmrahGuideView> {
  late PageController _pageController;
  late MapController _mapController;

  // Auto-tracking state (Location subscription remains in View)
  StreamSubscription<Position>? _locationSubscription;
  _SaiZone _currentZone = _SaiZone.none;
  LatLng? _currentLatLng;

  // Safa & Marwa Coordinates
  static const double _safaLat = 21.422200;
  static const double _safaLon = 39.827250;
  static const double _marwaLat = 21.425950;
  static const double _marwaLon = 39.827650;
  static const double _proximityThreshold = 35.0; // meters

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _updateLocationSubscription(bool isAutoTracking) {
    _locationSubscription?.cancel();
    if (isAutoTracking) {
      final locationService = LocationService();
      _locationSubscription = locationService.getLocationStream().listen(
        _processLocationUpdate,
        onError: (e) {
          context.read<UmrahGuideBloc>().add(const UpdateAutoTracking(false));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('error_prefix'.tr(args: [e.toString()]))),
          );
        },
      );
    }
  }

  void _processLocationUpdate(Position position) {
    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });

    final state = context.read<UmrahGuideBloc>().state;
    if (state is! UmrahGuideLoaded) return;

    // Auto-center map
    if (state.isAutoTracking) {
      _mapController.move(_currentLatLng!, 17.5);
    }

    final double distToSafa = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _safaLat,
      _safaLon,
    );
    final double distToMarwa = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _marwaLat,
      _marwaLon,
    );

    if (distToSafa < _proximityThreshold) {
      if (_currentZone != _SaiZone.safa) {
        _onZoneReached(_SaiZone.safa, state);
      }
    } else if (distToMarwa < _proximityThreshold) {
      if (_currentZone != _SaiZone.marwa) {
        _onZoneReached(_SaiZone.marwa, state);
      }
    } else {
      _currentZone = _SaiZone.none;
    }
  }

  void _onZoneReached(_SaiZone zone, UmrahGuideLoaded state) {
    setState(() {
      _currentZone = zone;
    });

    bool lapIncremented = false;
    int laps = state.saiLaps;

    if (zone == _SaiZone.marwa && laps % 2 == 0 && laps < 7) {
      laps++;
      lapIncremented = true;
    } else if (zone == _SaiZone.safa && laps % 2 != 0 && laps < 7) {
      laps++;
      lapIncremented = true;
    }

    if (lapIncremented) {
      context.read<UmrahGuideBloc>().add(UpdateSaiLaps(laps));
      _onLapCompleted();
    }
  }

  void _onLapCompleted() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 500, 200, 500]);
    }
  }

  Widget _buildSaiMap(UmrahGuideLoaded state) {
    final theme = context.ramadanTheme;
    final safa = LatLng(_safaLat, _safaLon);
    final marwa = LatLng(_marwaLat, _marwaLon);

    // Determine target based on current lap (0-indexed _saiLaps)
    // Lap 0, 2, 4, 6 -> Going to Marwa
    // Lap 1, 3, 5 -> Going to Safa
    final isGoingToMarwa = state.saiLaps % 2 == 0;
    final targetLatLng = isGoingToMarwa ? marwa : safa;
    final startLatLng = isGoingToMarwa ? safa : marwa;

    return Container(
      height: 280,
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.primary.withOpacity(0.1), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: safa,
              initialZoom: 17.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ramadan_assistant.app',
                tileBuilder: (context, tileWidget, tile) {
                  return ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      theme.primary.withOpacity(0.05),
                      BlendMode.srcATop,
                    ),
                    child: tileWidget,
                  );
                },
              ),
              PolylineLayer(
                polylines: [
                  // Full Path (Background)
                  Polyline(
                    points: [safa, marwa],
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                  ),
                  // Active Leg (Navigation Style)
                  Polyline(
                    points: [startLatLng, targetLatLng],
                    color: Colors.blue.shade600,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Safa Premium Marker
                  Marker(
                    point: safa,
                    width: 60,
                    height: 60,
                    child: _buildLocationMarker(
                      label: 'safa'.tr(),
                      icon: Icons.place_rounded,
                      color: theme.secondary,
                      isTarget: !isGoingToMarwa,
                    ),
                  ),
                  // Marwa Premium Marker
                  Marker(
                    point: marwa,
                    width: 60,
                    height: 60,
                    child: _buildLocationMarker(
                      label: 'marwa'.tr(),
                      icon: Icons.place_rounded,
                      color: Colors.redAccent,
                      isTarget: isGoingToMarwa,
                    ),
                  ),
                  // Directional Arrow (Pulse on path)
                  if (_currentLatLng != null)
                    Marker(
                      point: _getMidPoint(_currentLatLng!, targetLatLng),
                      width: 30,
                      height: 30,
                      child: Transform.rotate(
                        angle: _getBearing(_currentLatLng!, targetLatLng),
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: Colors.white,
                          size: 24,
                          shadows: [
                            Shadow(color: Colors.blue.shade900, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  // User Real-time Marker
                  if (_currentLatLng != null)
                    Marker(
                      point: _currentLatLng!,
                      width: 45,
                      height: 45,
                      child: _buildUserMarker(),
                    ),
                ],
              ),
            ],
          ),
          // Directional HUD
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.navigation_rounded,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isGoingToMarwa
                              ? 'going_to_marwa'.tr()
                              : 'going_to_safa'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'sai_lap_count'.tr(
                            args: [(state.saiLaps + 1).toString(), '7'],
                          ),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMarker({
    required String label,
    required IconData icon,
    required Color color,
    required bool isTarget,
  }) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isTarget ? Colors.blue : color,
              width: isTarget ? 3 : 2,
            ),
            boxShadow: isTarget
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMarker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(
          Icons.person_pin_circle_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  double _getBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * (math.pi / 180.0);
    final lon1 = start.longitude * (math.pi / 180.0);
    final lat2 = end.latitude * (math.pi / 180.0);
    final lon2 = end.longitude * (math.pi / 180.0);

    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    return math.atan2(y, x);
  }

  LatLng _getMidPoint(LatLng p1, LatLng p2) {
    return LatLng(
      (p1.latitude + p2.latitude) / 2,
      (p1.longitude + p2.longitude) / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UmrahGuideBloc, UmrahGuideState>(
      builder: (context, state) {
        if (state is UmrahGuideInitial || state is UmrahGuideLoading) {
          return Scaffold(
            backgroundColor: context.ramadanTheme.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is UmrahGuideError) {
          return Scaffold(
            backgroundColor: context.ramadanTheme.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('error_prefix'.tr(args: [state.message])),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<UmrahGuideBloc>().add(LoadUmrahProgress()),
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is UmrahGuideLoaded) {
          return Scaffold(
            backgroundColor: context.ramadanTheme.background,
            body: _buildBody(context, state),
          );
        }

        return Scaffold(
          backgroundColor: context.ramadanTheme.background,
          body: Center(child: Text('something_went_wrong'.tr())),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, UmrahGuideLoaded state) {
    final steps = state.progress;
    final firstIncomplete = steps.indexWhere((s) => !s.completed);
    final targetPage = firstIncomplete != -1
        ? firstIncomplete
        : steps.length - 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != targetPage) {
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });

    final theme = context.ramadanTheme;
    final completedCount = steps.where((s) => s.completed).length;
    final progress = steps.isEmpty ? 0.0 : completedCount / steps.length;

    return Column(
      children: [
        // 1. Wizard Header with Progress
        Container(
          padding: EdgeInsets.fromLTRB(20, context.paddingTop + 10, 20, 20),
          decoration: BoxDecoration(
            color: theme.primary,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'umrah_title'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      context.read<UmrahGuideBloc>().add(ResetUmrahProgress());
                      context.read<UmrahGuideBloc>().add(
                        const UpdateTawafCircuits(0),
                      );
                      context.read<UmrahGuideBloc>().add(
                        const UpdateSaiLaps(0),
                      );
                      context.read<UmrahGuideBloc>().add(
                        const UpdateMaqamToggle(false),
                      );
                      context.read<UmrahGuideBloc>().add(
                        const UpdateZamzamToggle(false),
                      );
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          completedCount == steps.length
                              ? 'may_allah_accept_umrah'.tr()
                              : 'umrah_progress_label'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.secondary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$completedCount/${steps.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Steps PageView
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final isNext =
                  !steps[index].completed &&
                  (index == 0 || (index > 0 && steps[index - 1].completed));

              return _buildStepPage(
                context,
                steps[index],
                index,
                steps.length,
                isNext,
                state,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepPage(
    BuildContext context,
    UmrahProgressData step,
    int index,
    int totalSteps,
    bool isNext,
    UmrahGuideLoaded state,
  ) {
    final theme = context.ramadanTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Icon & Title
          Center(
            child: Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primary.withOpacity(0.1),
              ),
              child: Center(
                child: (index + 1 >= 3 && index + 1 <= 5)
                    ? SvgPicture.asset(
                        'assets/${index + 1}.svg',
                        width: 40,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          theme.primary,
                          BlendMode.srcIn,
                        ),
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                      ),
              ),
            ),
          ),

          Center(
            child: Text(
              step.step.tr(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Center(child: _buildStatusChip(context, step, isNext)),

          const SizedBox(height: 32),

          Text(
            'guidelines_title'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: theme.primary,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildGuidelineWidgets(context, step.step, step.completed, state),

          const SizedBox(height: 24),

          // Inline Dua Sections
          // Inline Dua Sections
          if (step.step == 'step_ihram') ...[
            // Ishtirat Dua inline
            _buildInlineDuaSection(
              context,
              icon: Icons.info_outline_rounded,
              title: 'ishtirat_dua'.tr(),
              color: theme.primary,
              children: [
                Text(
                  UmrahDuas.ishtiratInfo,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: theme.textSecondary,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                DuaWidget(
                  arabicText: UmrahDuas.ishtiratFull,
                  translation: UmrahDuas.ishtirat.translation ?? '',
                ),
                const SizedBox(height: 8),
                Text(
                  'ihram_dua_instruction'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tawaf/Sai fixed duas inline (Ihram only)
            _buildInlineDuaCategorySection(
              context,
              icon: Icons.menu_book_rounded,
              title: 'fixed_tawaf_sai_duas'.tr(),
              color: theme.secondary,
              duas: UmrahDuas.tawafSaiDuas,
            ),
          ],

          // Other single-dua steps (e.g. Halaq)
          if (step.step != 'step_tawaf' &&
              step.step != 'step_sai' &&
              _getDuaArabic(step.step).isNotEmpty) ...[
            _buildSectionTitle(context, 'adhkar_title'.tr()),
            const SizedBox(height: 12),
            DuaWidget(
              arabicText: _getDuaArabic(step.step),
              translation: _getDuaTranslation(step.step),
            ),
          ],

          const SizedBox(height: 40),

          // Primary Action Button (Complete / Next)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (!step.completed) {
                  if (_canCompleteStep(step.step, state)) {
                    context.read<UmrahGuideBloc>().add(
                      CompleteUmrahStep(step.id),
                    );
                    if (step.step == 'step_tahlul') {
                      UmrahStorageService.getInstance().then((service) {
                        service.completeActiveTrip();
                      });
                    }
                    if (index == totalSteps - 1) {
                      _showCompletionBottomSheet(context);
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: step.completed
                    ? theme.secondary
                    : theme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: (step.completed ? theme.secondary : theme.primary)
                    .withOpacity(0.4),
              ),
              child: Text(
                step.completed
                    ? 'completed'.tr()
                    : (step.step == 'step_tawaf' &&
                              !_canCompleteStep(step.step, state)
                          ? 'complete_tawaf_first'.tr()
                          : 'complete_button'.tr()),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    UmrahProgressData step,
    bool isNext,
  ) {
    final theme = context.ramadanTheme;
    Color? chipColor;
    String label;
    IconData icon;

    if (step.completed) {
      chipColor = theme.secondary;
      label = 'completed'.tr();
      icon = Icons.check_circle_rounded;
    } else if (isNext) {
      chipColor = theme.secondary;
      label = 'current_stage'.tr();
      icon = Icons.play_circle_rounded;
    } else {
      chipColor = theme.textDim;
      label = 'waiting'.tr();
      icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = context.ramadanTheme;
    return Text(
      title,
      style: context.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.primary,
      ),
    );
  }

  Widget _buildInlineDuaSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(icon, size: 20, color: color),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          iconColor: color,
          collapsedIconColor: color,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInlineDuaCategorySection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required List<UmrahDua> duas,
  }) {
    final theme = context.ramadanTheme;
    final categories = duas.map((e) => e.category).toSet().toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(icon, size: 20, color: color),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          iconColor: color,
          collapsedIconColor: color,
          children: [
            for (final cat in categories) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Text(
                  cat ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: theme.primary,
                  ),
                ),
              ),
              ...duas
                  .where((d) => d.category == cat)
                  .map(
                    (dua) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DuaWidget(
                        arabicText: dua.arabic,
                        translation: dua.translation ?? '',
                        source: dua.source,
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGuidelineWidgets(
    BuildContext context,
    String? step,
    bool completed,
    UmrahGuideLoaded state,
  ) {
    if (step == null) return [];
    final theme = context.ramadanTheme;
    final points = _getGuidelinePoints(step);

    return List.generate(points.length, (index) {
      final point = points[index];

      if (step == 'step_tawaf' && index == 0 && !completed) {
        return _buildTawafRoundsSection(context, state);
      }

      if (step == 'step_tawaf' && index == 3 && !completed) {
        return _buildMaqamToggle(point, state.isPrayedAtMaqam, (val) {
          context.read<UmrahGuideBloc>().add(UpdateMaqamToggle(val));
        });
      }
      if (step == 'step_tawaf' && index == 4 && !completed) {
        return _buildIOSToggle(point, state.isDrunkZamzam, (val) {
          context.read<UmrahGuideBloc>().add(UpdateZamzamToggle(val));
        });
      }

      if (step == 'step_sai' && index == 0 && !completed) {
        return Column(
          children: [
            _buildAutoTrackingSwitch(state.isAutoTracking),
            const SizedBox(height: 16),
            if (state.isAutoTracking) _buildSaiMap(state),
            _buildSaiInteractiveProgress(context, state),
          ],
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(point, style: context.textTheme.bodyMedium)),
          ],
        ),
      );
    });
  }

  Widget _buildAutoTrackingSwitch(bool isAutoTracking) {
    final theme = context.ramadanTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isAutoTracking
            ? theme.primary.withOpacity(0.08)
            : theme.cardSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAutoTracking
              ? theme.primary.withOpacity(0.2)
              : theme.textDim.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAutoTracking
                ? Icons.location_on_rounded
                : Icons.location_off_rounded,
            color: isAutoTracking ? theme.primary : theme.textDim,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'auto_tracking_title'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isAutoTracking ? theme.primary : theme.textPrimary,
                  ),
                ),
                Text(
                  isAutoTracking
                      ? 'auto_tracking_active'.tr()
                      : 'auto_tracking_inactive'.tr(),
                  style: TextStyle(fontSize: 11, color: theme.textSecondary),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isAutoTracking,
            activeColor: theme.primary,
            onChanged: (val) {
              context.read<UmrahGuideBloc>().add(UpdateAutoTracking(val));
              _updateLocationSubscription(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaiInteractiveProgress(
    BuildContext context,
    UmrahGuideLoaded state,
  ) {
    final theme = context.ramadanTheme;
    final completedLaps = state.saiLaps;
    final maxLaps = 7;
    final roundNames = UmrahDuas.saiRoundNames;

    return Column(
      children: [
        // Sai Header
        Container(
          height: 160,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/image/safa_marwa_header.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: theme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.mosque_rounded,
                    size: 64,
                    color: theme.primary.withOpacity(0.3),
                  ),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
              // Progress overlay
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'السعي بين الصفا والمروة',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '$completedLaps / 7',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Mini progress bar for Sai
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 6,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: theme.textDim.withOpacity(0.1),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: completedLaps / maxLaps,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  colors: [theme.secondary, theme.primary],
                ),
              ),
            ),
          ),
        ),

        // 7 Lap Cards
        ...List.generate(7, (roundIndex) {
          final isCompleted = roundIndex < completedLaps;
          final isActive = roundIndex == completedLaps;
          final isPending = roundIndex > completedLaps;
          final lapName = roundNames[roundIndex];
          final roundDuas = UmrahDuas.getSaiRoundDuas(roundIndex);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: isActive
                  ? () => _showSaiRoundSheet(
                      context,
                      roundIndex,
                      roundDuas,
                      lapName,
                      state,
                    )
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? theme.success.withOpacity(0.08)
                      : isActive
                      ? theme.primary.withOpacity(0.06)
                      : theme.cardSurface.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompleted
                        ? theme.success.withOpacity(0.3)
                        : isActive
                        ? theme.primary.withOpacity(0.4)
                        : theme.textDim.withOpacity(0.08),
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: theme.primary.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Lap number circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? theme.success
                            : isActive
                            ? theme.primary
                            : theme.textDim.withOpacity(0.15),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: theme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 22,
                              )
                            : Text(
                                '${roundIndex + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : theme.textDim,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lapName,
                            style: TextStyle(
                              fontWeight: isActive || isCompleted
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isPending
                                  ? theme.textDim
                                  : theme.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          if (isActive)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'اضغط هنا للبدء والدعاء',
                                style: TextStyle(
                                  color: theme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          else if (isCompleted)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'مكتمل بحمد الله',
                                style: TextStyle(
                                  color: theme.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Status Icon / Action Area
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                    else if (isPending)
                      Icon(
                        Icons.lock_rounded,
                        color: theme.textDim.withOpacity(0.5),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),

        if (completedLaps == 7) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.celebration_rounded, color: theme.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'sai_done'.tr(),
                    style: TextStyle(
                      color: theme.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<UmrahGuideBloc>().add(const UpdateSaiLaps(6));
                  },
                  child: Text('تراجع', style: TextStyle(color: theme.success)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showSaiRoundSheet(
    BuildContext context,
    int roundIndex,
    List<UmrahDua> roundDuas,
    String roundName,
    UmrahGuideLoaded state,
  ) {
    final theme = context.ramadanTheme;
    final isGoingToMarwa =
        roundIndex % 2 == 0; // Even indexes are towards Marwa
    final umrahBloc = context.read<UmrahGuideBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.cardSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Minimal drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Sheet Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions_walk_rounded,
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roundName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimary,
                              ),
                            ),
                            Text(
                              isGoingToMarwa
                                  ? 'من الصفا إلى المروة'
                                  : 'من المروة إلى الصفا',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Duas List
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: roundDuas.length,
                    itemBuilder: (context, index) {
                      final dua = roundDuas[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DuaWidget(
                          arabicText: dua.arabic,
                          translation: dua.translation ?? '',
                          source: dua.source,
                        ),
                      );
                    },
                  ),
                ),

                // Complete Action Button
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    MediaQuery.of(context).padding.bottom + 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardSurface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.success,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Complete lap
                          umrahBloc.add(UpdateSaiLaps(roundIndex + 1));
                          Navigator.pop(sheetContext);

                          if (roundIndex < 6) {
                            // Auto-open next lap after a brief delay for animation
                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () {
                                if (context.mounted) {
                                  _showSaiRoundSheet(
                                    context,
                                    roundIndex + 1,
                                    UmrahDuas.getSaiRoundDuas(roundIndex + 1),
                                    UmrahDuas.saiRoundNames[roundIndex + 1],
                                    state,
                                  );
                                }
                              },
                            );
                          } else {
                            // Celebrate if this was the last round
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم السعي بحمد الله',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                backgroundColor: theme.success,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle_rounded),
                        label: Text(
                          roundIndex == 6
                              ? 'إتمام السعي'
                              : 'إتمام الشوط والانتقال للتالي',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTawafRoundsSection(
    BuildContext context,
    UmrahGuideLoaded state,
  ) {
    final theme = context.ramadanTheme;
    final completedRounds = state.tawafCircuits;
    final roundDuas = UmrahDuas.tawafRoundDuas;
    final roundNames = UmrahDuas.tawafRoundNames;

    return Column(
      children: [
        // Hero Header Image
        Container(
          height: 160,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/image/tawaf_header.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: theme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.mosque_rounded,
                    size: 64,
                    color: theme.primary.withOpacity(0.3),
                  ),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
              // Progress overlay
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الطواف حول الكعبة',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '$completedRounds / 7',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Mini progress bar
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 6,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: theme.textDim.withOpacity(0.1),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: completedRounds / 7,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  colors: [theme.secondary, theme.primary],
                ),
              ),
            ),
          ),
        ),

        // 7 Round Cards
        ...List.generate(7, (roundIndex) {
          final isCompleted = roundIndex < completedRounds;
          final isActive = roundIndex == completedRounds;
          final isPending = roundIndex > completedRounds;
          final roundName = roundNames[roundIndex];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: isActive
                  ? () => _showTawafRoundSheet(
                      context,
                      roundIndex,
                      roundDuas[roundIndex],
                      roundName,
                      state,
                    )
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? theme.success.withOpacity(0.08)
                      : isActive
                      ? theme.primary.withOpacity(0.06)
                      : theme.cardSurface.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompleted
                        ? theme.success.withOpacity(0.3)
                        : isActive
                        ? theme.primary.withOpacity(0.4)
                        : theme.textDim.withOpacity(0.08),
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: theme.primary.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Round number circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? theme.success
                            : isActive
                            ? theme.primary
                            : theme.textDim.withOpacity(0.15),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: theme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 22,
                              )
                            : Text(
                                '${roundIndex + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : theme.textDim,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Round info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roundName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: isPending
                                  ? theme.textDim
                                  : theme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isCompleted
                                ? 'تم ✓'
                                : isActive
                                ? 'اضغط لفتح الأدعية والأذكار'
                                : 'في الانتظار',
                            style: TextStyle(
                              fontSize: 12,
                              color: isCompleted
                                  ? theme.success
                                  : isActive
                                  ? theme.primary
                                  : theme.textDim,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action icon
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: theme.primary,
                          size: 20,
                        ),
                      )
                    else if (isPending)
                      Icon(
                        Icons.lock_outline_rounded,
                        color: theme.textDim.withOpacity(0.3),
                        size: 18,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Success message
        if (completedRounds == 7)
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: theme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: theme.success, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'tawaf_done'.tr(),
                    style: TextStyle(
                      color: theme.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showTawafRoundSheet(
    BuildContext context,
    int roundIndex,
    List<UmrahDua> duas,
    String roundName,
    UmrahGuideLoaded state,
  ) {
    final theme = context.ramadanTheme;
    final umrahBloc = context.read<UmrahGuideBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.textDim.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [theme.primary, theme.secondary],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${roundIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roundName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'أدعية وأذكار هذا الشوط',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: theme.textDim),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Duas list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: duas.length + 1, // +1 for Hajr Aswad image
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      // Hajr Aswad illustration
                      return Container(
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 20),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/image/hajr_aswad.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      );
                    }

                    final dua = duas[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dua.category != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                dua.category!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primary,
                                ),
                              ),
                            ),
                          DuaWidget(
                            arabicText: dua.arabic,
                            translation: dua.translation ?? '',
                            source: dua.source,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Mark Complete Button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        umrahBloc.add(UpdateTawafCircuits(roundIndex + 1));
                        Navigator.pop(sheetContext);

                        if (roundIndex < 6) {
                          // Auto-open next lap after a brief delay for animation
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (context.mounted) {
                              _showTawafRoundSheet(
                                context,
                                roundIndex + 1,
                                UmrahDuas.tawafRoundDuas[roundIndex + 1],
                                UmrahDuas.tawafRoundNames[roundIndex + 1],
                                state,
                              );
                            }
                          });
                        }
                      },
                      icon: const Icon(Icons.check_circle_rounded),
                      label: Text(
                        roundIndex < 6
                            ? 'إتمام $roundName والانتقال للتالي'
                            : 'إتمام الطواف',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                        shadowColor: theme.primary.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaqamToggle(String text, bool value, Function(bool) onChanged) {
    final theme = context.ramadanTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: value ? theme.success.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? theme.success.withOpacity(0.3)
              : theme.textDim.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // Maqam Ibrahim illustration
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/image/maqam_ibrahim.png',
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontSize: 14, color: theme.textPrimary),
                ),
              ),
              Switch.adaptive(value: value, onChanged: (v) => onChanged(v)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIOSToggle(String text, bool value, Function(bool) onChanged) {
    final theme = context.ramadanTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: value ? theme.success.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: theme.textPrimary),
            ),
          ),
          Switch.adaptive(value: value, onChanged: (v) => onChanged(v)),
        ],
      ),
    );
  }

  bool _canCompleteStep(String? step, UmrahGuideLoaded state) {
    if (step == 'step_tawaf') {
      return state.tawafCircuits == 7 &&
          state.isPrayedAtMaqam &&
          state.isDrunkZamzam;
    }
    if (step == 'step_sai') {
      return state.saiLaps == 7;
    }
    return true;
  }

  List<String> _getGuidelinePoints(String step) {
    String keyPrefix = '';
    int count = 0;
    switch (step) {
      case 'step_ihram':
        keyPrefix = 'guide_ihram';
        count = 6;
        break;
      case 'step_entrance':
        keyPrefix = 'guide_entrance';
        count = 3;
        break;
      case 'step_tawaf':
        keyPrefix = 'guide_tawaf';
        count = 5;
        break;
      case 'step_sai':
        keyPrefix = 'guide_sai';
        count = 5;
        break;
      case 'step_tahlul':
        keyPrefix = 'guide_tahlul';
        count = 3;
        break;
    }

    if (keyPrefix.isEmpty) return ['Follow the Sunnah.'];
    return List.generate(count, (i) => '${keyPrefix}_${i + 1}'.tr());
  }

  String _getDuaArabic(String? step) {
    switch (step) {
      case 'step_ihram':
        return 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً. لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لاَ شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعِّمَةَ لَكَ وَالْمُلْكَ، لاَ شَرِيكَ لَكَ.';
      case 'step_tawaf':
        return 'رَبَّنَا آتِنَا فِي الدِّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ.';
      case 'step_sai':
        return 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ فَلَا جُنَاحَ عَلَيْهِ أَنْ يَطَّوَّفَ بِهِمَا وَمَنْ تَطَوَّعَ خَيْرًا فَإِنَّ اللَّهَ شَاكِرٌ عَلِيمٌ.';
      default:
        return '';
    }
  }

  String _getDuaTranslation(String? step) {
    if (step == null) return '';
    String key = '';
    switch (step) {
      case 'step_ihram':
        key = 'dua_ihram_trans';
        break;
      case 'step_tawaf':
        key = 'dua_tawaf_trans';
        break;
      case 'step_sai':
        key = 'dua_sai_trans';
        break;
    }
    if (key.isEmpty) return '';
    // Assuming .tr() is a valid extension method for localization.
    // If 'key' is not found in localization, it will typically return the key itself or a fallback.
    // The instruction "undefined transliteration" might imply that these keys are not defined in the localization files.
    // Without access to the localization setup, I'm keeping the .tr() call as it's syntactically correct.
    // If the issue is that the keys are truly undefined in the localization files, that's an external configuration problem.
    return key.tr();
  }

  void _showCompletionBottomSheet(BuildContext context) {
    final theme = context.ramadanTheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.cardSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.textDim.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'accept_title'.tr(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'accept_message'.tr(),
              style: TextStyle(
                fontSize: 15,
                color: theme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'close'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
