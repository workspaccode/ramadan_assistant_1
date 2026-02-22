import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FallingFanousOverlay extends StatefulWidget {
  final VoidCallback onFinished;

  const FallingFanousOverlay({super.key, required this.onFinished});

  @override
  State<FallingFanousOverlay> createState() => _FallingFanousOverlayState();

  static void show(BuildContext context) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) =>
          FallingFanousOverlay(onFinished: () => entry.remove()),
    );
    Overlay.of(context).insert(entry);
  }
}

class _FallingFanousOverlayState extends State<FallingFanousOverlay>
    with TickerProviderStateMixin {
  final List<_FanousItem> _items = [];
  final Random _random = Random();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Initial batch
    for (int i = 0; i < 15; i++) {
      _addItem();
    }

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished();
      }
    });
  }

  void _addItem() {
    final startX = _random.nextDouble();
    final size = 40.0 + _random.nextDouble() * 60.0;
    final delay = _random.nextDouble() * 2.0;
    final duration = 2.0 + _random.nextDouble() * 2.0;

    _items.add(
      _FanousItem(startX: startX, size: size, delay: delay, duration: duration),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: _items.map((item) {
          return _FallingFanous(item: item, parentController: _controller);
        }).toList(),
      ),
    );
  }
}

class _FanousItem {
  final double startX;
  final double size;
  final double delay;
  final double duration;

  _FanousItem({
    required this.startX,
    required this.size,
    required this.delay,
    required this.duration,
  });
}

class _FallingFanous extends StatelessWidget {
  final _FanousItem item;
  final AnimationController parentController;

  const _FallingFanous({required this.item, required this.parentController});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: parentController,
      builder: (context, child) {
        // Calculate internal progress for this specific item
        final totalElapsed =
            parentController.value * 4.0; // controller total duration
        final itemProgress = (totalElapsed - item.delay) / item.duration;

        if (itemProgress < 0 || itemProgress > 1) {
          return const SizedBox.shrink();
        }

        final y = itemProgress * (screenHeight + 100) - 100;
        final x = item.startX * (screenWidth - item.size);

        // Add subtle rotation
        final rotation = sin(itemProgress * 10) * 0.2;

        return Positioned(
          top: y,
          left: x,
          child: Transform.rotate(
            angle: rotation,
            child: SizedBox(
              width: item.size,
              height: item.size,
              child: Lottie.asset('assets/animations/tes.json', repeat: true),
            ),
          ),
        );
      },
    );
  }
}
