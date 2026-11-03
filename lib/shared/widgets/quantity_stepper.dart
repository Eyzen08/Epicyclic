import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 20,
    this.compact = false,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final size = compact ? 28.0 : 34.0;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            size: size,
            enabled: quantity > min,
            onPressed: () => onChanged(quantity - 1),
          ),
          SizedBox(
            width: compact ? 26 : 32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontSize: compact ? 12.5 : 14),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            size: size,
            enabled: quantity < max,
            onPressed: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.size,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: enabled ? onPressed : null,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? palette.textPrimary
              : palette.textSecondary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
