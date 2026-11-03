import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.path,
    this.fit = BoxFit.contain,
    this.padding = const EdgeInsets.all(8),
  });

  final String path;
  final BoxFit fit;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return _Fallback(padding: padding, palette: context.palette);
    }
    final isRemote = path.startsWith('http://') || path.startsWith('https://');
    final image = isRemote
        ? Image.network(
            path,
            fit: fit,
            errorBuilder: (context, error, stackTrace) =>
                _Fallback(padding: padding, palette: context.palette),
          )
        : Image.asset(
            path,
            fit: fit,
            errorBuilder: (context, error, stackTrace) =>
                _Fallback(padding: padding, palette: context.palette),
          );
    return Padding(padding: padding, child: image);
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.padding, required this.palette});

  final EdgeInsets padding;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: palette.textSecondary.withValues(alpha: 0.5),
          size: 32,
        ),
      ),
    );
  }
}
