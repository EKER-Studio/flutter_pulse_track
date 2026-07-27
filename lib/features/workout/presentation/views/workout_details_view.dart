import 'package:pulse_track/core/presentation/theme/app_colors.dart';
import 'package:pulse_track/features/workout/domain/models/workout_session.dart';
import 'package:pulse_track/features/workout/presentation/utils/heart_rate_export_helper.dart';
import 'package:pulse_track/features/workout/presentation/utils/heart_rate_zones.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

/// Full-screen details view for a single completed or in-progress workout session.
///
/// Displays a header card with session date and device name, a summary grid
/// showing average BPM, peak BPM, duration, and sample count, and a custom-
/// painted BPM waveform chart colored by heart-rate zones.
///
/// Navigated to from the workout history list via the workout feature route.
class WorkoutDetailsView extends StatelessWidget {
  /// Creates a [WorkoutDetailsView] instance for the given [session].
  const WorkoutDetailsView({required this.session, super.key});

  static const Color _kCardBackgroundColor = AppColors.surfaceBackground;
  static const Color _kBadgeBackgroundColor = AppColors.badgeBackground;
  static const Color _kAvgBpmIconColor = AppColors.statIconAvg;
  static const Color _kPeakBpmIconColor = AppColors.statIconPeak;
  static const Color _kDurationIconColor = AppColors.statIconDuration;
  static const Color _kSamplesIconColor = AppColors.statIconSamples;
  static const double _kDefaultPadding = 16.0;
  static const double _kCardBorderRadius = 12.0;
  static const double _kBadgeBorderRadius = 6.0;
  static const double _kChartHeight = 250.0;
  static const double _kSectionSpacing = 24.0;
  static const double _kSubSectionSpacing = 12.0;
  static const double _kTileSpacing = 12.0;

  /// The workout session whose details are displayed.
  final WorkoutSession session;

  /// Builds the workout details screen with header, summary grid, and BPM chart using [context].
  @override
  Widget build(BuildContext context) {
    // Format once so the duration string is shared between the header badge
    // and the summary grid tile.
    final duration = _formatDuration(session.startTime, session.endTime);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Workout Details',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: Semantics(
          button: true,
          label: 'Back to workout history',
          child: IconButton(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: 'Back to workout history',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Share workout as CSV',
            child: IconButton(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.share),
              tooltip: 'Share workout as CSV',
              onPressed: () {
                HeartRateExportHelper.shareWorkoutAsCsv(context, session);
              },
            ),
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
                  Semantics(
                    label:
                        'Workout date: ${_formatDate(session.startTime)}, duration: $duration, sensor: ${session.deviceName.isEmpty ? 'Unknown Sensor' : session.deviceName}',
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _kCardBackgroundColor,
                        borderRadius: BorderRadius.circular(_kCardBorderRadius),
                        border: Border.all(
                          color: AppColors.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(_kDefaultPadding),
                        child: ExcludeSemantics(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDate(session.startTime),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
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
                                      borderRadius: BorderRadius.circular(
                                        _kBadgeBorderRadius,
                                      ),
                                    ),
                                    child: Text(
                                      duration,
                                      style: const TextStyle(
                                        color: AppColors.accentBlue,
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
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: _kSectionSpacing),

                  // Summary grid
                  const Text(
                    'Summary',
                    style: TextStyle(
                      color: AppColors.textPrimary,
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
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: _kSubSectionSpacing),
                  if (session.bpmSamples.isEmpty ||
                      session.bpmSamples.any((s) => s <= 0))
                    Semantics(
                      label: 'Heart rate chart: No workout data captured',
                      child: Container(
                        width: double.infinity,
                        height: _kChartHeight,
                        decoration: BoxDecoration(
                          color: _kCardBackgroundColor,
                          borderRadius: BorderRadius.circular(
                            _kCardBorderRadius,
                          ),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.monitor_heart,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: _kSubSectionSpacing),
                              Text(
                                'No workout data captured',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getEmptyDataReason(session),
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Semantics(
                      label:
                          'Heart rate waveform chart showing ${session.bpmSamples.length} samples over time. Average heart rate ${session.avgBpm} BPM, Peak heart rate ${session.maxBpm} BPM.',
                      child: Container(
                        width: double.infinity,
                        height: _kChartHeight,
                        decoration: BoxDecoration(
                          color: _kCardBackgroundColor,
                          borderRadius: BorderRadius.circular(
                            _kCardBorderRadius,
                          ),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
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
                    ),

                  if (session.bpmSamples.isNotEmpty &&
                      !session.bpmSamples.any((s) => s <= 0))
                    const SizedBox(height: _kDefaultPadding),
                  if (session.bpmSamples.isNotEmpty &&
                      !session.bpmSamples.any((s) => s <= 0))
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

  /// Builds a single summary tile showing an icon, a numeric [value], and a [label].
  Widget _summaryTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: const EdgeInsets.all(_kDefaultPadding),
        decoration: BoxDecoration(
          color: _kCardBackgroundColor,
          borderRadius: BorderRadius.circular(_kCardBorderRadius),
          border: Border.all(color: AppColors.borderSubtle, width: 1),
        ),
        child: Column(
          children: [
            ExcludeSemantics(child: Icon(icon, color: iconColor, size: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return intl.DateFormat('E, MMM d, y').format(date);
  }

  /// Returns a human-readable duration string from [start] to [end].
  ///
  /// If [end] is `null`, returns "In Progress" to indicate an active session.
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

  /// Returns a user-friendly explanation for why the BPM chart area is empty.
  ///
  /// Distinguishes between an incomplete session, a sensor disconnect, and
  /// a session that ran but recorded no valid heart-rate samples.
  String _getEmptyDataReason(WorkoutSession session) {
    if (session.endTime == null) {
      return 'The workout was not completed';
    }
    if (session.bpmSamples.isEmpty) {
      return 'The sensor may have disconnected before data was captured';
    }
    return 'No valid heart rate data was recorded';
  }
}

/// Displays a color-coded legend for the heart-rate training zones.
///
/// Each zone is rendered as a colored dot followed by its label and the
/// corresponding percentage range of maximum heart rate.
class _HrZoneLegend extends StatelessWidget {
  const _HrZoneLegend();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Heart rate training zones legend: ${kHeartRateZones.map((z) => '${z.label} ${(z.minPercent * 100).toInt()} to ${(z.maxPercent * 100).toInt()} percent').join(', ')}',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: List.generate(
          kHeartRateZones.length,
          (i) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: kHeartRateZones[i].color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${kHeartRateZones[i].label} ${(kHeartRateZones[i].minPercent * 100).toInt()}%-${(kHeartRateZones[i].maxPercent * 100).toInt()}%',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  /// Creates a [BpmChart] painter for the given BPM [samples], [startTime], and [endTime].
  BpmChart({
    required this.samples,
    required this.startTime,
    required this.endTime,
  });

  /// Individual BPM readings ordered chronologically.
  final List<int> samples;

  /// Timestamp of the first sample in the session.
  final DateTime startTime;

  /// Timestamp of the last sample, or `null` if the session is still active.
  final DateTime? endTime;

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
    final rangeMin = (bpmMin - padding).toDouble();
    final rangeMax = (bpmMax + padding).toDouble();
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

    // Precompute coordinates and build the fill path in a single pass.
    // Guard: when samples.length == 1, divisor would be 0, producing NaN offsets.
    final divisor = samples.length > 1 ? samples.length - 1 : 1;

    // Idiomatically initialize a fixed-size list in Dart
    final points = List<Offset>.generate(samples.length, (i) {
      final x = (i / divisor) * chartWidth;
      final yRatio = (samples[i] - rangeMin) / effectiveRange;
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

    // BPM waveform line with zone-colored segments
    final linePaint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < samples.length - 1; i++) {
      linePaint.color = getZoneColor(samples[i]);
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    // Gradient fill under the line
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.chartFillStart, AppColors.chartFillEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant BpmChart oldDelegate) {
    if (oldDelegate.samples.length != samples.length) return true;
    for (int i = 0; i < samples.length; i++) {
      if (oldDelegate.samples[i] != samples[i]) return true;
    }
    return false;
  }

  /// Paints a centered "No data" label when the sample list is empty.
  void _drawEmpty(Canvas canvas, Size size) {
    const labelStyle = TextStyle(color: AppColors.textSecondary, fontSize: 14);

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
