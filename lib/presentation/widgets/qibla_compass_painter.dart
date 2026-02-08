import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class QiblaCompassPainter extends CustomPainter {
  final double qiblaAngle;
  final String north;
  final String east;
  final String south;
  final String west;
  final String qiblaText;

  QiblaCompassPainter({
    required this.qiblaAngle,
    required this.north,
    required this.east,
    required this.south,
    required this.west,
    required this.qiblaText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    // Outer circle (gray)
    Paint outerCircle = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, outerCircle);

    // Inner circle (filled)
    Paint innerCircle = Paint()
      ..color = Colors.grey[100]!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 10, innerCircle);

    // Draw cardinal marks (N, E, S, W)
    _drawCardinalMarks(canvas, center, radius);

    // Draw degree marks
    _drawDegreeMarks(canvas, center, radius);

    // Qibla arrow (Large Green)
    _drawQiblaArrow(canvas, center, radius, qiblaAngle);

    // Center text
    _drawCenterText(canvas, center);
  }

  void _drawCardinalMarks(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Cardinal directions
    final directions = [
      {'text': 'N\n$north', 'angle': 0.0, 'color': Colors.red},
      {'text': 'E\n$east', 'angle': 90.0, 'color': Colors.black},
      {'text': 'S\n$south', 'angle': 180.0, 'color': Colors.black},
      {'text': 'W\n$west', 'angle': 270.0, 'color': Colors.black},
    ];

    for (var dir in directions) {
      double angle = (dir['angle'] as double) * pi / 180;
      double x = center.dx + (radius - 40) * cos(angle - pi / 2);
      double y = center.dy + (radius - 40) * sin(angle - pi / 2);

      textPainter.text = TextSpan(
        text: dir['text'] as String,
        style: TextStyle(
          color: dir['color'] as Color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawDegreeMarks(Canvas canvas, Offset center, double radius) {
    Paint markPaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 2;

    for (int i = 0; i < 360; i += 10) {
      double angle = i * pi / 180 - pi / 2;
      double markLength = (i % 30 == 0) ? 15 : 8;

      double x1 = center.dx + (radius - 5) * cos(angle);
      double y1 = center.dy + (radius - 5) * sin(angle);
      double x2 = center.dx + (radius - 5 - markLength) * cos(angle);
      double y2 = center.dy + (radius - 5 - markLength) * sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), markPaint);
    }
  }

  void _drawQiblaArrow(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
  ) {
    double angleRad = (angle - 90) * pi / 180;

    Paint arrowLine = Paint()
      ..color = Colors.green
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    double arrowLength = radius * 0.7;
    double endX = center.dx + arrowLength * cos(angleRad);
    double endY = center.dy + arrowLength * sin(angleRad);

    canvas.drawLine(center, Offset(endX, endY), arrowLine);

    Path arrowHead = Path();
    double headSize = 20;

    arrowHead.moveTo(endX, endY);
    arrowHead.lineTo(
      endX - headSize * cos(angleRad - pi / 6),
      endY - headSize * sin(angleRad - pi / 6),
    );
    arrowHead.lineTo(
      endX - headSize * cos(angleRad + pi / 6),
      endY - headSize * sin(angleRad + pi / 6),
    );
    arrowHead.close();

    Paint arrowHeadPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowHead, arrowHeadPaint);

    Paint centerDot = Paint()
      ..color = Colors.green[700]!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, centerDot);
  }

  void _drawCenterText(Canvas canvas, Offset center) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: qiblaText,
        style: TextStyle(
          color: Colors.green[900],
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + 20),
    );
  }

  @override
  bool shouldRepaint(covariant QiblaCompassPainter oldDelegate) {
    return oldDelegate.qiblaAngle != qiblaAngle ||
        oldDelegate.qiblaText != qiblaText;
  }
}
