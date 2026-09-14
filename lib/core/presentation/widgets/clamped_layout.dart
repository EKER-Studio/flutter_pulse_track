import 'package:flutter/material.dart';

/// A responsive layout helper that clamps its [child] to a maximum width and centers it horizontally.
class ClampedLayout extends StatelessWidget {
  /// The child widget to clamp.
  final Widget child;

  /// Optional uniform padding applied inside the clamped area.
  final EdgeInsetsGeometry? padding;

  /// Maximum width of the clamped content.
  final double maxWidth;

  /// Alignment of the clamped content.
  final AlignmentGeometry alignment;

  /// Creates a [ClampedLayout].
  const ClampedLayout({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = 600,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
