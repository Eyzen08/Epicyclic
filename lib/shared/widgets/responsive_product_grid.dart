import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared responsive rules for product grids.
///
/// The breakpoints are tuned for the surfaces Epicyclic actually ships on:
/// small Android phones (320–430 px), tablets (600–1024 px), and wide web
/// layouts (1280 px and up). Keeping the maths in one place is what stops card
/// heights drifting between Home, Catalog, and Wishlist.
class ProductGridMetrics {
  const ProductGridMetrics({
    required this.columns,
    required this.mainAxisExtent,
    required this.spacing,
  });

  final int columns;
  final double mainAxisExtent;
  final double spacing;

  static int columnsFor(double width) {
    if (width < 520) return 2;
    if (width < 760) return 3;
    if (width < 1040) return 4;
    return 5;
  }

  static double spacingFor(double width) {
    if (width < 520) return 12;
    if (width < 760) return 14;
    return 18;
  }

  /// Image area capped so cards never become billboards on desktop.
  static const double _maxImageExtent = 210;

  /// Vertical room needed for brand, name, tagline, price, and padding.
  static const double _textExtent = 124;

  factory ProductGridMetrics.of(double width) {
    final columns = columnsFor(width);
    final spacing = spacingFor(width);
    final usable = width - spacing * (columns - 1);
    final columnWidth = usable <= 0 ? width : usable / columns;
    final imageExtent = math.min(columnWidth, _maxImageExtent);
    return ProductGridMetrics(
      columns: columns,
      mainAxisExtent: imageExtent + _textExtent,
      spacing: spacing,
    );
  }

  SliverGridDelegate delegate() {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      mainAxisExtent: mainAxisExtent,
    );
  }
}

/// GridView wrapper that adapts its column count to the incoming width.
///
/// Use this for grids that live inside a scroll view (Home, Wishlist). For
/// slivers use the [delegate] from [ProductGridMetrics] instead.
class ResponsiveProductGrid extends StatelessWidget {
  const ResponsiveProductGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
    this.physics,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = ProductGridMetrics.of(constraints.maxWidth);
        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          padding: padding,
          itemCount: itemCount,
          gridDelegate: metrics.delegate(),
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

/// Constrains page content on wide viewports so text lines stay readable and
/// card grids keep a sane maximum width.
class ResponsivePageBody extends StatelessWidget {
  const ResponsivePageBody({
    super.key,
    required this.child,
    this.maxWidth = 1180,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
