import 'package:flutter/material.dart';

import '../../../workout/infrastructure/models/workout_session_dto.dart';

/// Full-screen details for a single workout session: header, summary grid,
/// and a custom-painted BPM waveform chart.
class WorkoutDetailsView extends StatelessWidget {
  const WorkoutDetailsView({required this.session, super.key});

  final WorkoutSessionDto session;

  @override
  Widget build(BuildContext context) {
    final duration = _formatDuration(
      session.startTime,
      session.endTime,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
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
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(6),
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

                  const SizedBox(height: 24),

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
                          iconColor: const Color(0xFFFF6B6B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryTile(
                          label: 'Peak BPM',
                          value: '${session.maxBpm}',
                          icon: Icons.favorite_border,
                          iconColor: const Color(0xFFFFD93D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryTile(
                          label: 'Duration',
                          value: duration,
                          icon: Icons.timer,
                          iconColor: const Color(0xFF6BCB77),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryTile(
                          label: 'Samples',
                          value: '${session.bpmSamples.length}',
                          icon: Icons.show_chart,
                          iconColor: const Color(0xFF4D96FF),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // BPM chart
                  const Text(
                    'Heart Rate Over Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
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

                  const SizedBox(height: 32),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
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
    final rangeMin = (bpmMax - padding).toDouble();
    final rangeMax = (bpmMin + padding).toDouble();
    final effectiveRange = rangeMax - rangeMin;

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

    // BPM waveform line
    final linePaint = Paint()
      ..color = const Color(0xFFFF6B6B)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    for (int i = 0; i < samples.length; i++) {
      final x = chartLeft + (i / (samples.length - 1)) * size.width;
      final ratio = (samples[i] - rangeMin) / effectiveRange;
      final y = chartBottom - (ratio * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Gradient fill under the line
    final fillPath = Path();
    fillPath.addPolygon(
      List.generate(
        samples.length,
        (i) => Offset(
          chartLeft + (i / (samples.length - 1)) * size.width,
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
          const Color(0xFFFF6B6B).withAlpha(76),
          const Color(0xFFFF6B6B).withAlpha(0),
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
