import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/workout/presentation/utils/heart_rate_zones.dart';

/// Custom painter that draws a BPM waveform chart from raw heart-rate samples.
///
/// The chart maps sample index to the horizontal axis and BPM values to the
/// vertical axis. Each line segment is colored according to the heart-rate
/// zone the sample falls into. A gradient fill is drawn beneath the waveform.
///
/// **Chart math notes:**
/// - A 10% vertical *padding* is added around the min/max BPM range so the
///   waveform never clips at the absolute top or bottom edge of the canvas.
///   The padding is clamped to `[0, 20]` BPM to avoid excessive whitespace.
/// - A *divisor* guard (`samples.length > 1 ? samples.length - 1 : 1`)
///   prevents division by zero when only a single sample is provided,
///   which would otherwise produce `NaN` / `Infinity` offsets and crash
///   the canvas paint pass.
class BpmChart extends CustomPainter {
  BpmChart({
    required this.samples,
    required this.startTime,
    required this.endTime,
    this.emptyLabel = 'No data',
    this.scrubFraction,
  });

  /// Individual BPM readings ordered chronologically.
  final List<int> samples;

  /// Timestamp of the first sample in the session.
  final DateTime startTime;

  /// Timestamp of the last sample, or `null` if the session is still active.
  final DateTime? endTime;

  /// Localized text rendered when [samples] is empty.
  final String emptyLabel;

  /// Optional active horizontal scrubbing position as a fraction [0.0, 1.0].
  final double? scrubFraction;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) {
      _drawEmpty(canvas, size);
      return;
    }

    final bpmMin = samples.reduce((a, b) => a < b ? a : b);
    final bpmMax = samples.reduce((a, b) => a > b ? a : b);

    // Vertical padding: expands the Y-axis range so the waveform never clips
    // at the canvas edge. Clamped to [0, 20] BPM to avoid excessive whitespace.
    final padding = (bpmMax - bpmMin).toDouble().clamp(0.0, 20.0);
    final rangeMin = bpmMin - padding;
    final rangeMax = bpmMax + padding;
    final effectiveRange = rangeMax - rangeMin == 0 ? 1.0 : rangeMax - rangeMin;

    final chartWidth = size.width;
    final chartHeight = size.height;

    // Grid lines and labels
    final gridPaint = Paint()
      ..color = AppColors.chartGridLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const gridLabelStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 10,
    );

    // Draw 4 horizontal grid lines
    for (int i = 0; i < 4; i++) {
      final ratio = i / 3;
      final bpmValue = rangeMin + effectiveRange * ratio;
      final y = chartHeight - (ratio * chartHeight);

      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);

      final labelPainter = TextPainter(
        text: TextSpan(text: '${bpmValue.round()}', style: gridLabelStyle),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(canvas, Offset(4, y - 6));
    }

    // Performance downsampling: if the sample count exceeds screen resolution (e.g. 300-500 points),
    // sample at a fixed stride step to guarantee smooth 60FPS rendering without frame drops.
    final maxTargetPoints = (chartWidth * 1.5).clamp(100.0, 500.0).toInt();
    final step = (samples.length / maxTargetPoints).ceil().clamp(
      1,
      samples.length,
    );

    final displaySamples = <int>[];
    for (int i = 0; i < samples.length; i += step) {
      displaySamples.add(samples[i]);
    }
    if (displaySamples.isEmpty || displaySamples.last != samples.last) {
      displaySamples.add(samples.last);
    }

    // Precompute coordinates and build the fill path in a single pass.
    // Guard: when displaySamples.length == 1, divisor would be 0, producing NaN offsets.
    final divisor = displaySamples.length > 1 ? displaySamples.length - 1 : 1;

    final points = List<Offset>.generate(displaySamples.length, (i) {
      final x = (i / divisor) * chartWidth;
      final yRatio = (displaySamples[i] - rangeMin) / effectiveRange;
      final y = chartHeight - (yRatio * chartHeight);
      return Offset(x, y);
    });

    final fillPath = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        fillPath.moveTo(points[i].dx, points[i].dy);
      } else {
        fillPath.lineTo(points[i].dx, points[i].dy);
      }
    }

    // Close the fill region down to the bottom of the chart.
    fillPath.lineTo(chartWidth, chartHeight);
    fillPath.lineTo(0, chartHeight);
    fillPath.close();

    // Gradient fill under the line
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.chartFillStart, AppColors.chartFillEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    // BPM waveform line with zone-colored segments
    final linePaint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < displaySamples.length - 1; i++) {
      linePaint.color = getZoneColor(displaySamples[i]);
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    // Interactive scrub indicator line & dot
    final activeFraction = scrubFraction;
    if (activeFraction != null && displaySamples.isNotEmpty) {
      final scrubDisplayIndex = (activeFraction * (displaySamples.length - 1))
          .round()
          .clamp(0, displaySamples.length - 1);
      final scrubPoint = points[scrubDisplayIndex];

      final scrubLinePaint = Paint()
        ..color = AppColors.accentBlue
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(scrubPoint.dx, 0),
        Offset(scrubPoint.dx, chartHeight),
        scrubLinePaint,
      );

      final circlePaint = Paint()
        ..color = getZoneColor(displaySamples[scrubDisplayIndex])
        ..style = PaintingStyle.fill;
      canvas.drawCircle(scrubPoint, 6.0, circlePaint);

      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(scrubPoint, 6.0, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BpmChart oldDelegate) {
    if (oldDelegate.scrubFraction != scrubFraction) return true;
    if (oldDelegate.emptyLabel != emptyLabel) return true;
    if (oldDelegate.samples.length != samples.length) return true;
    for (int i = 0; i < samples.length; i++) {
      if (oldDelegate.samples[i] != samples[i]) return true;
    }
    return false;
  }

  void _drawEmpty(Canvas canvas, Size size) {
    const labelStyle = TextStyle(color: AppColors.textSecondary, fontSize: 14);

    final tp = TextPainter(
      text: TextSpan(text: emptyLabel, style: labelStyle),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );
  }
}
