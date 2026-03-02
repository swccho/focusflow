import 'package:flutter/material.dart';

/// Desktop padding: 24 default, 16 for small widths.
double _desktopPaddingHorizontal(double width) {
  if (width < 700) return 16;
  return 24;
}

double _desktopPaddingVertical(double height) {
  if (height < 600) return 16;
  return 24;
}

/// Subtle radial gradient for desktop. Full-width layout with outer padding only.
/// No max-width or center constraint; content uses full space.
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.4,
          colors: isDark
              ? [
                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  Theme.of(context).colorScheme.surface,
                ]
              : [
                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  Theme.of(context).colorScheme.surface,
                ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padH = _desktopPaddingHorizontal(constraints.maxWidth);
          final padV = _desktopPaddingVertical(constraints.maxHeight);
          return Padding(
            padding: EdgeInsets.fromLTRB(padH, padV, padH, padV),
            child: SizedBox(
              width: constraints.maxWidth - 2 * padH,
              height: constraints.maxHeight - 2 * padV,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
