import 'package:flutter/material.dart';

import 'package:pulse_track/core/presentation/theme/app_colors.dart';

/// Animated heart icon widget that pulses proportionally to the live [bpm].
class AnimatedHeartIcon extends StatefulWidget {
  /// Current heart rate in beats per minute, determining pulse tempo.
  final int bpm;

  /// Icon size in logical pixels.
  final double size;

  /// Icon color override.
  final Color color;

  const AnimatedHeartIcon({
    super.key,
    required this.bpm,
    this.size = 44,
    this.color = AppColors.accentRed,
  });

  @override
  State<AnimatedHeartIcon> createState() => _AnimatedHeartIconState();
}

class _AnimatedHeartIconState extends State<AnimatedHeartIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _calculateDuration(widget.bpm),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.18,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(AnimatedHeartIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bpm != widget.bpm) {
      _controller.duration = _calculateDuration(widget.bpm);
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    }
  }

  Duration _calculateDuration(int bpm) {
    final clampedBpm = bpm.clamp(30, 240);
    return Duration(milliseconds: (30000 / clampedBpm).round());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Icon(Icons.favorite, color: widget.color, size: widget.size),
    );
  }
}
