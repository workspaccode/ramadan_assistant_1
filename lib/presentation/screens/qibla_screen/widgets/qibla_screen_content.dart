import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/presentation/screens/qibla_screen/bloc/qibla_screen_bloc.dart';
import 'package:ramadan_assistant/presentation/widgets/location_error_widget.dart';

class QiblaScreenContent extends StatefulWidget {
  const QiblaScreenContent({super.key});

  @override
  State<QiblaScreenContent> createState() => _QiblaScreenContentState();
}

class _QiblaScreenContentState extends State<QiblaScreenContent> {
  bool _isMapView = false;
  final LatLng _kaabaLocation = const LatLng(21.4225, 39.8262);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QiblaScreenBloc, QiblaScreenState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.backgroundColor,
          appBar: AppBar(
            title: Text('qibla_title'.tr()),
            backgroundColor: context.backgroundColor,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  _isMapView ? Icons.explore_outlined : Icons.map_outlined,
                ),
                onPressed: () => setState(() => _isMapView = !_isMapView),
                tooltip: _isMapView ? 'show_compass'.tr() : 'show_map'.tr(),
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, QiblaScreenState state) {
    if (state is QiblaScreenInitial || state is QiblaScreenLoading) {
      return _buildLoadingState(context);
    } else if (state is QiblaLocationRequired) {
      return LocationErrorWidget(
        error: 'location_required_msg'.tr(),
        callback: () =>
            context.read<QiblaScreenBloc>().add(StartQiblaUpdates()),
      );
    } else if (state is QiblaScreenLoaded) {
      return _isMapView
          ? _buildMapView(context, state)
          : _buildQiblaContent(context, state.direction);
    } else if (state is QiblaScreenError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('error_prefix'.tr(args: [state.message])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<QiblaScreenBloc>().add(StartQiblaUpdates()),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(context.primaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            'getting_qibla_direction'.tr(),
            style: TextStyle(
              color: context.onBackgroundColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(BuildContext context, QiblaScreenLoaded state) {
    final userLocation = LatLng(
      state.position.latitude,
      state.position.longitude,
    );

    return FlutterMap(
      options: MapOptions(initialCenter: userLocation, initialZoom: 15),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.ramadan_assistant',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [userLocation, _kaabaLocation],
              color: context.primaryColor,
              strokeWidth: 4,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: userLocation,
              width: 50,
              height: 50,
              child: const Icon(
                Icons.my_location,
                color: Colors.blue,
                size: 30,
              ),
            ),
            Marker(
              point: _kaabaLocation,
              width: 50,
              height: 50,
              child: const Icon(Icons.mosque, color: Colors.green, size: 35),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQiblaContent(BuildContext context, QiblahDirection data) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 30),

          // Qibla Compass
          Stack(
            alignment: Alignment.center,
            children: [
              // Compass Rose (The background SVG)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: data.direction),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (context, angle, child) {
                  return Transform.rotate(
                    angle: (angle * (pi / 180) * -1),
                    child: child,
                  );
                },
                child: SvgPicture.asset(
                  'assets/compass.svg',
                  width: 280,
                  height: 280,
                ),
              ),

              // Qibla Needle (The arrow SVG)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: data.qiblah),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (context, angle, child) {
                  return Transform.rotate(
                    angle: (angle * (pi / 180)),
                    child: child,
                  );
                },
                child: SvgPicture.asset(
                  'assets/needle.svg',
                  width: 100,
                  height: 100,
                  colorFilter: ColorFilter.mode(
                    context.primaryColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),

              // Mecca Icon in Center
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.mosque, color: Colors.white, size: 40),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Info Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              elevation: 4,
              color: context.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      '${data.qiblah.toStringAsFixed(1)}°',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),
                    Text(
                      'from_north'.tr(),
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(),
                    ),
                    _buildInfoRow(
                      context,
                      'current_heading'.tr(),
                      '${data.direction.toStringAsFixed(1)}°',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      'offset_label'.tr(),
                      '${data.offset.toStringAsFixed(1)}°',
                      valueColor: data.offset.abs() < 5
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: context.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'instructions_title'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'qibla_instructions'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: context.onSurfaceColor.withValues(alpha: 0.8),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: context.onSurfaceColor),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? context.onSurfaceColor,
          ),
        ),
      ],
    );
  }
}
