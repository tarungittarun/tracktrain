import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/enums.dart';

/// Analog gauge + digital read-out speedometer rendered with a single
/// CustomPainter (no assets, no animation controllers — cheap on battery).
class AnalogSpeedometer extends StatelessWidget {
  const AnalogSpeedometer({
    super.key,
    required this.speedKmh,
    required this.unit,
    this.maxKmh = 180,
  });

  final double speedKmh;
  final SpeedUnitChoice unit;
  final double maxKmh;

  static const double _startAngleDeg = 135;
  static const double _sweepAngleDeg = 270;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shown = unit.convertFromKmh(speedKmh);

    return AspectRatio(
      aspectRatio: 1.25,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _GaugePainter(
              valueKmh: speedKmh.clamp(0, maxKmh).toDouble(),
              maxKmh: maxKmh,
              unit: unit,
              startAngleDeg: _startAngleDeg,
              sweepAngleDeg: _sweepAngleDeg,
              trackColor: scheme.surfaceContainerHighest,
              progressColor: scheme.primary,
              tickColor: scheme.outlineVariant,
              labelColor: scheme.onSurfaceVariant,
              needleColor: scheme.tertiary,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shown.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                  ),
                  Text(
                    unit.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
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
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.valueKmh,
    required this.maxKmh,
    required this.unit,
    required this.startAngleDeg,
    required this.sweepAngleDeg,
    required this.trackColor,
    required this.progressColor,
    required this.tickColor,
    required this.labelColor,
    required this.needleColor,
  });

  final double valueKmh;
  final double maxKmh;
  final SpeedUnitChoice unit;
  final double startAngleDeg;
  final double sweepAngleDeg;
  final Color trackColor;
  final Color progressColor;
  final Color tickColor;
  final Color labelColor;
  final Color needleColor;

  static double _deg(double degrees) => degrees * math.pi / 180.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + size.height * 0.08);
    final radius = math.min(size.width, size.height) * 0.42;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final start = _deg(startAngleDeg);
    final sweep = _deg(sweepAngleDeg);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawArc(arcRect, start, sweep, false, trackPaint);

    final fraction = (valueKmh / maxKmh).clamp(0.0, 1.0);
    if (fraction > 0.004) {
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..color = progressColor;
      canvas.drawArc(arcRect, start, sweep * fraction, false, progressPaint);
    }

    // Tick marks every 20 km/h with labels every 40.
    final tickPaint = Paint()
      ..strokeWidth = 2
      ..color = tickColor;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    for (var kmh = 0; kmh <= maxKmh; kmh += 20) {
      final angle = start + sweep * (kmh / maxKmh);
      final outer = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      final inner = center +
          Offset(math.cos(angle), math.sin(angle)) * (radius - 10);
      canvas.drawLine(inner, outer, tickPaint);

      if (kmh % 40 == 0) {
        final shown = unit.convertFromKmh(kmh.toDouble()).round();
        textPainter.text = TextSpan(
          text: '$shown',
          style: TextStyle(color: labelColor, fontSize: 9),
        );
        textPainter.layout();
        final labelPos = center +
            Offset(math.cos(angle), math.sin(angle)) * (radius - 22) -
            Offset(textPainter.width / 2, textPainter.height / 2);
        textPainter.paint(canvas, labelPos);
      }
    }

    // Needle.
    final needleAngle = start + sweep * fraction;
    final needleTip = center +
        Offset(math.cos(needleAngle), math.sin(needleAngle)) * (radius - 16);
    final needlePaint = Paint()
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = needleColor;
    canvas.drawLine(center, needleTip, needlePaint);
    canvas.drawCircle(center, 6, Paint()..color = needleColor);
    canvas.drawCircle(center, 2.5, Paint()..color = trackColor);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.valueKmh != valueKmh ||
      oldDelegate.maxKmh != maxKmh ||
      oldDelegate.unit != unit;
}
