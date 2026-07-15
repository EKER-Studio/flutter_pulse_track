import 'package:flutter/material.dart';

import 'package:ble_heart_rate_monitor/features/workout/infrastructure/models/workout_session_dto.dart';
import 'package:ble_heart_rate_monitor/features/workout/presentation/utils/heart_rate_export_helper.dart';
import 'package:ble_heart_rate_monitor/features/workout/presentation/utils/heart_rate_zones.dart';

/// Full-screen details for a single workout session: header, summary grid,
/// and a custom-painted BPM waveform chart.
class WorkoutDetailsView extends StatelessWidget {
  const WorkoutDetailsView({required this.session, super.key});

  static const Color _kBackgroundColor = Color(0xFF0D0D0D);
  static const Color _kCardBackgroundColor = Color(0xFF1E1E1E);
  static const Color _kBadgeBackgroundColor = Color(0xFF2A2A2A);
  static const Color _kAvgBpmIconColor = Color(0xFFFF6B6B);
  static const Color _kPeakBpmIconColor = Color(0xFFFFD93D);
  static const Color _kDurationIconColor = Color(0xFF6BCB77);
  static const Color _kSamplesIconColor = Color(0xFF4D96FF);
  static const double _kDefaultPadding = 16.0;
  static const double _kCardBorderRadius = 12.0;
  static const double _kBadgeBorderRadius = 6.0;
  static const double _kChartHeight = 250.0;
  static const double _kSectionSpacing = 24.0;
  static const double _kSubSectionSpacing = 12.0;
  static const double _kTileSpacing = 12.0;

  final WorkoutSessionDto session;

  @override
  Widget build(BuildContext context) {
    final duration = _formatDuration(
      session.startTime,
      session.endTime,
    );

    return Scaffold(
      backgroundColor: _kBackgroundColor,
      appBar: AppBar(
        backgroundColor: _kBackgroundColor,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Workout Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              HeartRateExportHelper.shareWorkoutAsCsv(context, session);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(_kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _kCardBackgroundColor,
                      borderRadius: BorderRadius.circular(_kCardBorderRadius),
                      border: Border.all(color: Colors.white10, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(_kDefaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(session.startTime),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _kBadgeBackgroundColor,
                                  borderRadius: BorderRadius.circular(_kBadgeBorderRadius),
                                ),
                                child: Text(
                                  duration,
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session.deviceName.isEmpty
                                ? 'Unknown Sensor'
                                : session.deviceName,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: _kSectionSpacing),

                  // Summary grid
                  const Text(
                    'Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryTile(
                          label: 'Average BPM',
                          value: '${session.avgBpm}',
                          icon: Icons.favorite,
                          iconColor: _kAvgBpmIconColor,
                        ),
                      ),
                       const SizedBox(width: _kTileSpacing),
                       Expanded(
                         child: _summaryTile(
                           label: 'Peak BPM',
                          value: '${session.maxBpm}',
                          icon: Icons.favorite_border,
                          iconColor: _kPeakBpmIconColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _kSubSectionSpacing),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryTile(
                          label: 'Duration',
                          value: duration,
                          icon: Icons.timer,
                          iconColor: _kDurationIconColor,
                        ),
                      ),
                       const SizedBox(width: _kTileSpacing),
                       Expanded(
                         child: _summaryTile(
                           label: 'Samples',
                          value: '${session.bpmSamples.length}',
                          icon: Icons.show_chart,
                          iconColor: _kSamplesIconColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: _kSectionSpacing),

                  // BPM chart
                  const Text(
                    'Heart Rate Over Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: _kSubSectionSpacing),
                  if (session.bpmSamples.isEmpty || session.bpmSamples.any((s) => s <= 0))
                    Container(
                      width: double.infinity,
                      height: _kChartHeight,
                      decoration: BoxDecoration(
                        color: _kCardBackgroundColor,
                        borderRadius: BorderRadius.circular(_kCardBorderRadius),
                        border: Border.all(color: Colors.white10, width: 1),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.monitor_heart,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: _kSubSectionSpacing),
                            Text(
                              'No workout data captured',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getEmptyDataReason(session),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: _kChartHeight,
                      decoration: BoxDecoration(
                        color: _kCardBackgroundColor,
                        borderRadius: BorderRadius.circular(_kCardBorderRadius),
                        border: Border.all(color: Colors.white10, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: CustomPaint(
                          painter: BpmChart(
                            samples: session.bpmSamples,
                            startTime: session.startTime,
                            endTime: session.endTime,
                          ),
                        ),
                      ),
                    ),

                  if (session.bpmSamples.isNotEmpty && !session.bpmSamples.any((s) => s <= 0))
                    const SizedBox(height: _kDefaultPadding),
                  if (session.bpmSamples.isNotEmpty && !session.bpmSamples.any((s) => s <= 0))
                    const _HrZoneLegend(),

                  const SizedBox(height: _kDefaultPadding * 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(_kDefaultPadding),
      decoration: BoxDecoration(
        color: _kCardBackgroundColor,
        borderRadius: BorderRadius.circular(_kCardBorderRadius),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDuration(DateTime start, DateTime? end) {
    if (end == null) return 'In Progress';
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (seconds > 0 || parts.isEmpty) parts.add('${seconds}s');
    return parts.join(' ');
  }

  String _getEmptyDataReason(WorkoutSessionDto session) {
    if (session.endTime == null) {
      return 'The workout was not completed';
    }
    if (session.bpmSamples.isEmpty) {
      return 'The sensor may have disconnected before data was captured';
    }
    return 'No valid heart rate data was recorded';
  }
}

class _HrZoneLegend extends StatelessWidget {
  const _HrZoneLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: List.generate(
        kHeartRateZones.length,
            (i) =>
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: kHeartRateZones[i].color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${kHeartRateZones[i].label} ${(kHeartRateZones[i]
                      .minPercent * 100).toInt()}%-${(kHeartRateZones[i]
                      .maxPercent * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

/// Custom painter that draws a BPM waveform chart from raw samples.
///
/// The chart maps the sample index to the horizontal axis and BPM values
/// to the vertical axis, clipping to the available bounds.
class BpmChart extends CustomPainter {
  BpmChart({
    required this.samples,
    required this.startTime,
    required this.endTime,
  });

  final List<int> samples;
  final DateTime startTime;
  final DateTime? endTime;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) {
      _drawEmpty(canvas, size);
      return;
    }

    final bpmMin = samples.reduce((a, b) => a < b ? a : b);
    final bpmMax = samples.reduce((a, b) => a > b ? a : b);

    // Add 10% padding to the BPM range so the line doesn't touch edges
    final padding = (bpmMax - bpmMin).toDouble().clamp(0.0, 20.0);
    final rangeMin = (bpmMin - padding).toDouble();
    final rangeMax = (bpmMax + padding).toDouble();
    final effectiveRange = rangeMax - rangeMin == 0 ? 1.0 : rangeMax - rangeMin;

    final double chartLeft = 0;
    final double chartRight = size.width;
    final double chartTop = 0;
    final double chartBottom = size.height;
    final double chartHeight = chartBottom - chartTop;

    // Grid lines and labels
    final gridPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final labelStyle = const TextStyle(
      color: Colors.grey,
      fontSize: 10,
    );

    // Draw 4 horizontal grid lines
    for (int i = 0; i < 4; i++) {
      final ratio = i / 3;
      final bpmValue = rangeMin + effectiveRange * ratio;
      final y = chartBottom - (ratio * chartHeight);

      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(chartRight, y),
        gridPaint,
      );

      final tp = TextPainter(
        text: TextSpan(text: '${bpmValue.round()}', style: labelStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(4, y - 6),
      );
    }

    final linePaint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // BPM waveform line with zone-colored segments
    final divisor = samples.length > 1 ? samples.length - 1 : 1;
    for (int i = 0; i < samples.length - 1; i++) {
      final x1 = chartLeft + (i / divisor) * size.width;
      final x2 = chartLeft + ((i + 1) / divisor) * size.width;
      final ratio1 = (samples[i] - rangeMin) / effectiveRange;
      final ratio2 = (samples[i + 1] - rangeMin) / effectiveRange;
      final y1 = chartBottom - (ratio1 * chartHeight);
      final y2 = chartBottom - (ratio2 * chartHeight);

      linePaint.color = getZoneColor(samples[i]);

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        linePaint,
      );
    }

    // Gradient fill under the line
    final fillPath = Path();
    fillPath.addPolygon(
      List.generate(
        samples.length,
            (i) => Offset(
          chartLeft + (i / divisor) * size.width,
          chartBottom -
              ((samples[i] - rangeMin) / effectiveRange) * chartHeight,
        ),
      ),
      false,
    );
    fillPath.lineTo(chartRight, chartBottom);
    fillPath.lineTo(chartLeft, chartBottom);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void _drawEmpty(Canvas canvas, Size size) {
    const labelStyle = TextStyle(
      color: Colors.grey,
      fontSize: 14,
    );

    final tp = TextPainter(
      text: const TextSpan(text: 'No data', style: labelStyle),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        (size.width - (labelStyle.fontSize! * 5)) / 2,
        size.height / 2 - 10,
      ),
    );
  }
}
