import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Dependency-free bar chart for the dashboard's weekly travel summary.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key, required this.data});

  /// (label, value) pairs, oldest first.
  final List<(String, double)> data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 150,
      child: CustomPaint(
        size: Size.infinite,
        painter: _BarChartPainter(
          data: data,
          barColor: scheme.primary,
          emptyColor: scheme.surfaceContainerHighest,
          labelColor: scheme.onSurfaceVariant,
          valueColor: scheme.onSurface,
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.data,
    required this.barColor,
    required this.emptyColor,
    required this.labelColor,
    required this.valueColor,
  });

  final List<(String, double)> data;
  final Color barColor;
  final Color emptyColor;
  final Color labelColor;
  final Color valueColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const labelHeight = 22.0;
    const valueHeight = 16.0;
    final chartHeight = size.height - labelHeight - valueHeight;
    final maxValue =
        data.map((d) => d.$2).reduce(math.max).clamp(1.0, double.infinity);

    final slot = size.width / data.length;
    final barWidth = math.min(slot * 0.52, 34.0);

    for (var i = 0; i < data.length; i++) {
      final (label, value) = data[i];
      final centerX = slot * i + slot / 2;
      final height = value <= 0 ? 0.0 : (value / maxValue) * chartHeight;
      final top = valueHeight + chartHeight - height;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - barWidth / 2, top, barWidth, height),
        const Radius.circular(6),
      );
      if (value > 0) {
        canvas.drawRRect(rect, Paint()..color = barColor);
      } else {
        final stub = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            centerX - barWidth / 2,
            valueHeight + chartHeight - 3,
            barWidth,
            3,
          ),
          const Radius.circular(1.5),
        );
        canvas.drawRRect(stub, Paint()..color = emptyColor);
      }

      if (value > 0) {
        _drawText(
          canvas,
          value >= 100 ? value.round().toString() : value.toStringAsFixed(1),
          Offset(centerX, top - 3),
          valueColor,
          9,
          TextAlign.center,
          anchorBottom: true,
        );
      }
      _drawText(
        canvas,
        label,
        Offset(centerX, size.height - labelHeight + 4),
        labelColor,
        9,
        TextAlign.center,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    Color color,
    double fontSize,
    TextAlign align, {
    bool anchorBottom = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();
    final dx = position.dx - painter.width / 2;
    final dy = anchorBottom ? position.dy - painter.height : position.dy;
    painter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) =>
      oldDelegate.data != data;
}
