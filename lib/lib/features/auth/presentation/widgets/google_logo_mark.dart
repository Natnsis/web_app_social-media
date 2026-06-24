import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Multi-color Google "G" mark for sign-in buttons.
class GoogleLogoMark extends StatelessWidget {
  final double size;

  const GoogleLogoMark({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoMarkPainter()),
    );
  }
}

class _GoogleLogoMarkPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = side * 0.48;
    final innerRadius = side * 0.30;
    final ring = outerRadius - innerRadius;

    void drawSegment(Color color, double start, double sweep) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius + ring / 2),
        start,
        sweep,
        false,
        paint,
      );
    }

    drawSegment(_red, math.pi * 0.72, math.pi * 0.55);
    drawSegment(_yellow, math.pi * 1.28, math.pi * 0.45);
    drawSegment(_green, math.pi * 1.73, math.pi * 0.55);
    drawSegment(_blue, math.pi * 0.08, math.pi * 0.62);

    canvas.drawRect(
      Rect.fromLTWH(
        center.dx,
        center.dy - ring * 0.42,
        outerRadius * 0.95,
        ring * 0.84,
      ),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
