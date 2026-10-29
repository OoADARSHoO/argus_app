import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Circular progress ring for Argus.
/// Draws a background track in border color and a foreground progress arc
/// starting at 12 o'clock with round stroke caps.
/// Reusable across sizes: 120px (Components), 160px (Break screen), and large (Support donut).
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.size,
    required this.strokeWidth,
    required this.color,
    this.child,
  });

  /// Progress fraction between 0.0 and 1.0.
  final double value;

  /// Diameter of the ring container in pixels.
  final double size;

  /// Thickness of the stroke in pixels.
  final double strokeWidth;

  /// Color of the active progress arc.
  final Color color;

  /// Optional widget displayed in the center of the ring.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _ProgressRingPainter(
          value: value,
          strokeWidth: strokeWidth,
          color: color,
          trackColor: AppColors.border,
        ),
        child: child != null ? Center(child: child) : null,
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.value,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  final double value;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc starting at 12 o'clock (-pi / 2)
    final clampedValue = value.clamp(0.0, 1.0);
    if (clampedValue > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(center: center, radius: radius);
      const startAngle = -math.pi / 2;
      final sweepAngle = clampedValue * 2 * math.pi;

      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
