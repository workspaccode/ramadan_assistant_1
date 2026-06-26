import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramadan_assistant/presentation/screens/adhan_screen/bloc/adhan_screen_bloc.dart';

class AdhanScreenContent extends StatefulWidget {
  const AdhanScreenContent({super.key});

  @override
  State<AdhanScreenContent> createState() => _AdhanScreenContentState();
}

class _AdhanScreenContentState extends State<AdhanScreenContent>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();

    // Auto-dismiss the Adhan screen after 5 minutes to prevent infinite wake lock and battery drain
    _autoDismissTimer = Timer(const Duration(minutes: 5), () {
      if (mounted) {
        context.read<AdhanScreenBloc>().add(DismissScreen());
        Navigator.pop(context);
      }
    });

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    _autoDismissTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.wb_sunny_outlined;
      case 'maghrib':
        return Icons.nightlight_round;
      case 'isha':
        return Icons.bedtime;
      default:
        return Icons.mosque;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdhanScreenBloc, AdhanScreenState>(
      listener: (context, state) {
        if (state is AdhanScreenDhikrCompleted) {
          // Auto-close after dhikr completion with a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) Navigator.pop(context);
          });
        }
      },
      builder: (context, state) {
        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              context.read<AdhanScreenBloc>().add(DismissScreen());
            }
          },
          child: Scaffold(
            body: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildBody(context, state),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AdhanScreenState state) {
    if (state is AdhanScreenDhikr) {
      return _buildDhikrView(context, state);
    }
    if (state is AdhanScreenDhikrCompleted) {
      return _buildCompletedView(context, state);
    }
    if (state is AdhanScreenActive) {
      return _buildAdhanView(context, state);
    }
    return const Center(child: CircularProgressIndicator());
  }

  // ── Main Adhan View ─────────────────────────────────────────────────────

  Widget _buildAdhanView(BuildContext context, AdhanScreenActive state) {
    final prayerName = state.prayerName;
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1628), Color(0xFF0D2F1E), Color(0xFF0A1628)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated glow circles
          _buildGlowEffects(size),

          // Stars/particles
          ..._buildStars(size),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar: Close button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: _buildGlassButton(
                      icon: Icons.close,
                      onTap: () {
                        context.read<AdhanScreenBloc>().add(DismissScreen());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Prayer icon with animated glow
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: _buildPrayerOrb(prayerName),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Call to prayer text
                Text(
                  'adhan_call_to_prayer'.tr(),
                  style: TextStyle(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.9),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Prayer name
                Text(
                  prayerName.toLowerCase().tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 12),

                // Current time
                Text(
                  DateFormat('HH:mm').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 3,
                    fontFamily: 'monospace',
                  ),
                ),

                const Spacer(flex: 3),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      // Start Dhikr button
                      _buildPrimaryButton(
                        label: 'start_dhikr'.tr(),
                        icon: Icons.auto_awesome,
                        onTap: () {
                          context.read<AdhanScreenBloc>().add(StartDhikr());
                          HapticFeedback.mediumImpact();
                        },
                      ),

                      const SizedBox(height: 16),

                      // Dismiss button
                      _buildSecondaryButton(
                        label: 'dismiss_btn'.tr(),
                        onTap: () {
                          context.read<AdhanScreenBloc>().add(DismissScreen());
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Dhikr View ──────────────────────────────────────────────────────────

  Widget _buildDhikrView(BuildContext context, AdhanScreenDhikr state) {
    final progress = state.target > 0 ? state.count / state.target : 0.0;

    return GestureDetector(
      onTap: () {
        context.read<AdhanScreenBloc>().add(IncrementDhikr());
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1628), Color(0xFF112240), Color(0xFF0A1628)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGlassButton(
                      icon: Icons.close,
                      onTap: () {
                        context.read<AdhanScreenBloc>().add(DismissScreen());
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      'post_prayer_adhkar'.tr(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Dhikr progress indicators (dots)
              _buildDhikrProgressDots(state.dhikrIndex),

              const SizedBox(height: 40),

              // Dhikr text
              Text(
                state.dhikrText,
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 48),

              // Circular counter
              Stack(
                alignment: Alignment.center,
                children: [
                  // Background ring
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 4,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  // Progress ring
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                  // Counter text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${state.count}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      Text(
                        '/ ${state.target}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Hint
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'tap_to_tasbih'.tr(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Completed View ──────────────────────────────────────────────────────

  Widget _buildCompletedView(
    BuildContext context,
    AdhanScreenDhikrCompleted state,
  ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1628), Color(0xFF0D2F1E), Color(0xFF0A1628)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Color(0xFFD4AF37),
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'may_allah_accept'.tr(),
              style: TextStyle(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.9),
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'good_deeds'.tr(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: _buildSecondaryButton(
                label: 'dismiss_btn'.tr(),
                onTap: () {
                  context.read<AdhanScreenBloc>().add(DismissScreen());
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable Widgets ────────────────────────────────────────────────────

  Widget _buildPrayerOrb(String prayerName) {
    final icon = _getPrayerIcon(prayerName);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFD4AF37).withValues(alpha: 0.15),
                const Color(0xFFD4AF37).withValues(alpha: 0.05),
                Colors.transparent,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFD4AF37,
                ).withValues(alpha: _glowAnimation.value * 0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 48),
          ),
        );
      },
    );
  }

  Widget _buildGlowEffects(Size size) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: size.height * 0.15,
              left: size.width * 0.5 - 100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(
                        0xFFD4AF37,
                      ).withValues(alpha: _glowAnimation.value * 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.2,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(
                        0xFF1E8E5C,
                      ).withValues(alpha: _glowAnimation.value * 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildStars(Size size) {
    final random = Random(42); // Fixed seed for consistent positions
    return List.generate(15, (i) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = 1.0 + random.nextDouble() * 2;

      return Positioned(
        left: x,
        top: y,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            final opacity =
                (0.2 + random.nextDouble() * 0.3) *
                (0.5 + _glowAnimation.value * 0.5);
            return Container(
              width: starSize,
              height: starSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: opacity),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildDhikrProgressDots(int currentIndex) {
    final labels = ['سبحان الله', 'الحمد لله', 'الله أكبر'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i == currentIndex;
        final isDone = i < currentIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Container(
                width: isActive ? 12 : 8,
                height: isActive ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? const Color(0xFFD4AF37)
                      : isActive
                      ? const Color(0xFFD4AF37).withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.2),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                labels[i],
                style: TextStyle(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w300,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 22),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFB8962E)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF0A1628), size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0A1628),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
