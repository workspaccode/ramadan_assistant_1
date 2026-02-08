import 'dart:async';
import 'dart:math' show pi, cos, sin;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';

import 'location_error_widget.dart';

class QiblaCompass extends StatefulWidget {
  const QiblaCompass({super.key});

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  Stream<LocationStatus> get stream => _locationStreamController.stream;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<LocationStatus>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator(radius: 20));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('checking_location'.tr()));
          }

          final locationStatus = snapshot.data!;

          if (locationStatus.enabled == true) {
            switch (locationStatus.status) {
              case LocationPermission.always:
              case LocationPermission.whileInUse:
                return const QiblahCompassWidget();

              case LocationPermission.denied:
                return LocationErrorWidget(
                  error: 'location_denied'.tr(),
                  callback: _checkLocationStatus,
                );

              case LocationPermission.deniedForever:
                return LocationErrorWidget(
                  error: 'location_permanently_denied'.tr(),
                  callback: _checkLocationStatus,
                );

              default:
                return LocationErrorWidget(
                  error: 'unknown_location_error'.tr(),
                  callback: _checkLocationStatus,
                );
            }
          } else {
            return LocationErrorWidget(
              error: 'location_service_disabled'.tr(),
              callback: _checkLocationStatus,
            );
          }
        },
      ),
    );
  }

  Future<void> _checkLocationStatus() async {
    try {
      final locationStatus = await FlutterQiblah.checkLocationStatus();

      if (locationStatus.enabled &&
          locationStatus.status == LocationPermission.denied) {
        await FlutterQiblah.requestPermissions();
        final newStatus = await FlutterQiblah.checkLocationStatus();
        _locationStreamController.sink.add(newStatus);
      } else {
        _locationStreamController.sink.add(locationStatus);
      }
    } catch (e) {
      print('Error checking location: $e');
    }
  }

  @override
  void dispose() {
    _locationStreamController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }
}

// ============================================
// البوصلة الرئيسية مع Calibration
// ============================================

class QiblahCompassWidget extends StatefulWidget {
  const QiblahCompassWidget({super.key});

  @override
  State<QiblahCompassWidget> createState() => _QiblahCompassWidgetState();
}

class _QiblahCompassWidgetState extends State<QiblahCompassWidget> {
  bool _showCalibration = false;
  Timer? _calibrationTimer;
  bool _hasShownCalibration = false; // 🔥 Flag جديد

  @override
  void initState() {
    super.initState();

    // بعد 3 ثواني، إذا لسه ما جت بيانات، اعرض رسالة المعايرة
    _calibrationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_hasShownCalibration) {
        setState(() {
          _showCalibration = true;
          _hasShownCalibration = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _calibrationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        // 🔥 لو البيانات وصلت، إلغي Timer بدون setState
        if (snapshot.hasData && !_hasShownCalibration) {
          _calibrationTimer?.cancel();
          _hasShownCalibration = true;
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(child: Text('no_compass_data'.tr()));
        }

        final qiblahDirection = snapshot.data!;

        return Stack(
          children: [
            _buildCompass(qiblahDirection),

            // شاشة المعايرة
            if (_showCalibration) _buildCalibrationOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 200,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 150,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.92),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أنيميشن دائري
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green.shade300,
                          ),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.screen_rotation_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'calibrating_compass'.tr(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'calibration_instruction'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // رسم الـ figure-8
                CustomPaint(
                  size: const Size(200, 100),
                  painter: Figure8Painter(),
                ),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'calibration_tips_title'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'calibration_tips'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showCalibration = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'got_it_continue'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    setState(() {
                      _showCalibration = false;
                    });
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.white60),
                  child: Text('skip_for_now'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompass(QiblahDirection qiblahDirection) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(), // 🔥 تحسين الـ scroll
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // البوصلة
          Stack(
            alignment: Alignment.center,
            children: [
              // البوصلة الدوارة
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: qiblahDirection.direction),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (context, angle, child) {
                  return Transform.rotate(
                    angle: (angle * (pi / 180) * -1),
                    child: child,
                  );
                },
                child: const CompassRose(),
              ),

              // أيقونة الكعبة في المنتصف
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.mosque, size: 50, color: Colors.white),
              ),

              // الإبرة (تشير للقبلة)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: qiblahDirection.qiblah),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (context, angle, child) {
                  return Transform.rotate(
                    angle: (angle * (pi / 180)),
                    child: child,
                  );
                },
                child: Icon(
                  Icons.navigation_rounded,
                  size: 90,
                  color: Theme.of(context).colorScheme.primary,
                  shadows: const [
                    Shadow(color: Colors.black26, blurRadius: 10),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // معلومات الاتجاه
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '${qiblahDirection.qiblah.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'from_north'.tr(),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'current_heading'.tr(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${qiblahDirection.direction.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'offset_label'.tr(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${qiblahDirection.offset.toStringAsFixed(1)}°',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: qiblahDirection.offset.abs() < 5
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // تعليمات
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'instructions_title'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
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
                    color: Colors.blue[900],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showCalibration = true;
                    });
                  },
                  icon: const Icon(Icons.settings_backup_restore),
                  label: Text('recalibrate_compass'.tr()),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ============================================
// رسم البوصلة
// ============================================

class CompassRose extends StatelessWidget {
  const CompassRose({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(
        painter: CompassRosePainter(
          north: 'north'.tr(),
          east: 'east'.tr(),
          south: 'south'.tr(),
          west: 'west'.tr(),
        ),
      ),
    );
  }
}

class CompassRosePainter extends CustomPainter {
  final String north;
  final String east;
  final String south;
  final String west;

  CompassRosePainter({
    required this.north,
    required this.east,
    required this.south,
    required this.west,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    final outerCirclePaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius - 10, outerCirclePaint);

    // Inner circle
    final innerCirclePaint = Paint()
      ..color = Colors.grey[100]!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 15, innerCirclePaint);

    // Marks
    final markPaint = Paint()..color = Colors.grey[700]!;

    for (int i = 0; i < 360; i += 10) {
      final angle = i * pi / 180 - pi / 2;
      final isMainDirection = i % 90 == 0;
      final markLength = isMainDirection ? 20.0 : 10.0;

      final startRadius = radius - 15;
      final endRadius = startRadius - markLength;

      final start = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );

      final end = Offset(
        center.dx + endRadius * cos(angle),
        center.dy + endRadius * sin(angle),
      );

      markPaint.strokeWidth = isMainDirection ? 3 : 1.5;
      canvas.drawLine(start, end, markPaint);
    }

    // Directions
    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final directions = [
      {'text': north, 'angle': 0.0, 'color': Colors.red},
      {'text': east, 'angle': 90.0, 'color': Colors.black},
      {'text': south, 'angle': 180.0, 'color': Colors.black},
      {'text': west, 'angle': 270.0, 'color': Colors.black},
    ];

    for (var dir in directions) {
      final angle = (dir['angle'] as double) * pi / 180 - pi / 2;
      final textRadius = radius - 45;

      final pos = Offset(
        center.dx + textRadius * cos(angle),
        center.dy + textRadius * sin(angle),
      );

      textPainter.text = TextSpan(
        text: dir['text'] as String,
        style: TextStyle(
          color: dir['color'] as Color,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================
// رسام Figure-8 للمعايرة
// ============================================

class Figure8Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final centerX = size.width / 2;
    final radius = size.height / 3;

    // رسم infinity symbol (∞)
    final path = Path();

    // Left loop
    path.addOval(
      Rect.fromCircle(
        center: Offset(centerX - radius * 0.8, centerY),
        radius: radius * 0.9,
      ),
    );

    // Right loop
    path.addOval(
      Rect.fromCircle(
        center: Offset(centerX + radius * 0.8, centerY),
        radius: radius * 0.9,
      ),
    );

    canvas.drawPath(path, paint);

    // سهم يوضح الاتجاه
    final arrowPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    arrowPath.moveTo(centerX + radius * 1.8, centerY);
    arrowPath.lineTo(centerX + radius * 1.5, centerY - 10);
    arrowPath.lineTo(centerX + radius * 1.5, centerY + 10);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
