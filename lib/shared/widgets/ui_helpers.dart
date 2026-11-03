import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

IconData categoryIcon(String key) {
  switch (key) {
    case 'gaming':
      return Icons.sports_esports_outlined;
    case 'keyboards':
      return Icons.keyboard_outlined;
    case 'mice':
      return Icons.mouse_outlined;
    case 'audio':
      return Icons.headphones_outlined;
    case 'mousepads':
      return Icons.grid_view_rounded;
    case 'accessories':
      return Icons.cable_rounded;
    case 'streaming':
      return Icons.podcasts_rounded;
    default:
      return Icons.devices_other_outlined;
  }
}

String categoryLabel(String id) {
  switch (id) {
    case 'gaming':
      return 'Gaming';
    case 'keyboards':
      return 'Keyboards';
    case 'mice':
      return 'Mice';
    case 'audio':
      return 'Audio';
    case 'mousepads':
      return 'Mousepads';
    case 'accessories':
      return 'Accessories';
    case 'streaming':
      return 'Streaming';
    default:
      return 'Gear';
  }
}

class DemoNotice extends StatelessWidget {
  const DemoNotice({
    super.key,
    required this.message,
    this.icon = Icons.science_outlined,
    this.margin = EdgeInsets.zero,
  });

  final String message;
  final IconData icon;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.warningSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.warning.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: palette.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: palette.textPrimary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.tone = InfoTone.info,
    this.margin = EdgeInsets.zero,
  });

  final String message;
  final IconData icon;
  final InfoTone tone;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (background, foreground) = switch (tone) {
      InfoTone.info => (palette.primarySoft, palette.primary),
      InfoTone.success => (palette.successSoft, palette.success),
      InfoTone.warning => (palette.warningSoft, palette.warning),
      InfoTone.danger => (palette.dangerSoft, palette.danger),
    };
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: palette.textPrimary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

enum InfoTone { info, success, warning, danger }

class StepDots extends StatelessWidget {
  const StepDots({
    super.key,
    required this.count,
    required this.index,
    this.activeColor,
  });

  final int count;
  final int index;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index
                  ? (activeColor ?? palette.primary)
                  : palette.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: emphasized ? palette.textPrimary : palette.textSecondary,
                fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.textPrimary,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
