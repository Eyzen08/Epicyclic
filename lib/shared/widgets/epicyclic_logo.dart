import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

class EpicyclicMark extends StatelessWidget {
  const EpicyclicMark({super.key, this.size = 36, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MarkPainter(color ?? context.palette.textPrimary),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final orbitRadius = unit * 0.31;
    final stroke = unit * 0.085;

    final ring = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fill = Paint()..color = color;

    // Open orbit, leaving a deliberate gap at the upper right.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: orbitRadius),
      0.55,
      4.9,
      false,
      ring,
    );

    // Core.
    canvas.drawCircle(center, unit * 0.19, fill);

    // Travelling node on the orbit.
    final node = Offset(
      center.dx + orbitRadius * 0.22,
      center.dy - orbitRadius * 0.975,
    );
    canvas.drawCircle(node, unit * 0.105, fill);
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

class EpicyclicLogo extends StatelessWidget {
  const EpicyclicLogo({
    super.key,
    this.markSize = 34,
    this.textSize = 26,
    this.color,
    this.showText = true,
  });

  final double markSize;
  final double textSize;
  final Color? color;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? context.palette.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        EpicyclicMark(size: markSize, color: foreground),
        if (showText) ...[
          const SizedBox(width: 10),
          Text(
            'Epicyclic',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: textSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.9,
              color: foreground,
              height: 1,
            ),
          ),
        ],
      ],
    );
  }
}

class DemoModeChip extends StatelessWidget {
  const DemoModeChip({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Tooltip(
      message: 'Local demo data. No live payments or fulfillment.',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 4 : 5,
        ),
        decoration: BoxDecoration(
          color: palette.warningSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: palette.warning.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.science_outlined,
              size: compact ? 12 : 14,
              color: palette.warning,
            ),
            const SizedBox(width: 4),
            Text(
              'DEMO',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: compact ? 9.5 : 10.5,
                letterSpacing: 0.7,
                fontWeight: FontWeight.w600,
                color: palette.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
