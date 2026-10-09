import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/l10n/app_localizations.dart';

/// Interactive chart displaying rolling live BPM telemetry samples with zoom capability.
class LiveBpmChart extends StatelessWidget {
  /// Recent heart rate readings (up to 40 samples).
  final List<int> samples;

  /// Whether vertical scale is auto-zoomed to the min/max of visible [samples].
  final bool isZoomed;

  /// Callback when user toggles chart zoom state.
  final VoidCallback onToggleZoom;

  const LiveBpmChart({
    super.key,
    required this.samples,
    required this.isZoomed,
    required this.onToggleZoom,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.liveBpmChartTitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(
                  isZoomed ? Icons.zoom_out : Icons.zoom_in,
                  color: AppColors.accentBlue,
                  size: 20,
                ),
                tooltip: isZoomed
                    ? l10n.chartZoomOutTooltip
                    : l10n.chartZoomInTooltip,
                onPressed: onToggleZoom,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _LiveBpmChartPainter(
                samples: samples,
                isZoomed: isZoomed,
                emptyLabel: l10n.chartNoData,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBpmChartPainter extends CustomPainter {
  final List<int> samples;
  final bool isZoomed;
  final String emptyLabel;

  _LiveBpmChartPainter({
    required this.samples,
    required this.isZoomed,
    required this.emptyLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width;
    final chartHeight = size.height;

    if (samples.isEmpty) {
      _drawEmpty(canvas, size);
      return;
    }

    final double effectiveMin;
    final double effectiveMax;

    if (isZoomed) {
      final minVal = samples.reduce((a, b) => a < b ? a : b).toDouble();
      final maxVal = samples.reduce((a, b) => a > b ? a : b).toDouble();
      final pad = ((maxVal - minVal) * 0.15).clamp(4.0, 15.0);
      effectiveMin = (minVal - pad).clamp(0.0, 300.0);
      effectiveMax = (maxVal + pad).clamp(0.0, 300.0);
    } else {
      effectiveMin = 0.0;
      effectiveMax = 220.0;
    }

    final effectiveRange = effectiveMax - effectiveMin == 0
        ? 1.0
        : effectiveMax - effectiveMin;

    _drawGrid(canvas, size, effectiveMin, effectiveRange);

    final divisor = samples.length > 1 ? samples.length - 1 : 1;
    final points = List<Offset>.generate(samples.length, (i) {
      final x = (i / divisor) * chartWidth;
      final yRatio = (samples[i] - effectiveMin) / effectiveRange;
      final y = (chartHeight - (yRatio * chartHeight)).clamp(0.0, chartHeight);
      return Offset(x, y);
    });

    // Fill gradient path underneath the waveform
    final fillPath = Path()
      ..moveTo(points.first.dx, chartHeight)
      ..lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }

    fillPath
      ..lineTo(points.last.dx, chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.chartFillStart, AppColors.chartFillEnd],
      ).createShader(Rect.fromLTWH(0, 0, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Line path
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final linePaint = Paint()
      ..color = AppColors.accentBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Highlight current (latest) point
    final lastPoint = points.last;
    final outerGlowPaint = Paint()
      ..color = AppColors.accentRed.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    final centerDotPaint = Paint()
      ..color = AppColors.accentRed
      ..style = PaintingStyle.fill;

    canvas.drawCircle(lastPoint, 6.0, outerGlowPaint);
    canvas.drawCircle(lastPoint, 3.5, centerDotPaint);
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double effectiveMin,
    double effectiveRange,
  ) {
    final gridPaint = Paint()
      ..color = AppColors.chartGridLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const gridLabelStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 9,
    );

    for (int i = 0; i < 4; i++) {
      final ratio = i / 3.0;
      final bpmValue = effectiveMin + effectiveRange * ratio;
      final y = size.height - (ratio * size.height);

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      final labelPainter = TextPainter(
        text: TextSpan(text: '${bpmValue.round()}', style: gridLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      labelPainter.paint(
        canvas,
        Offset(4, (y - 12).clamp(0.0, size.height - 12)),
      );
    }
  }

  void _drawEmpty(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: emptyLabel,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _LiveBpmChartPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.isZoomed != isZoomed ||
        oldDelegate.emptyLabel != emptyLabel;
  }
}
