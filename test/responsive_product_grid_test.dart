import 'package:epicyclic/shared/widgets/responsive_product_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget tile(BuildContext context, int index) {
  return Container(
    key: ValueKey('tile-$index'),
    decoration: BoxDecoration(
      color: Colors.blue.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

void main() {
  group('ProductGridMetrics', () {
    test('uses 2 columns on phones', () {
      for (final width in [320.0, 360.0, 390.0, 430.0]) {
        expect(ProductGridMetrics.columnsFor(width), 2, reason: '$width px');
      }
    });

    test('adds columns on tablets and wide screens', () {
      expect(ProductGridMetrics.columnsFor(600), 3);
      expect(ProductGridMetrics.columnsFor(768), 4);
      expect(ProductGridMetrics.columnsFor(1024), 4);
      expect(ProductGridMetrics.columnsFor(1280), 5);
      expect(ProductGridMetrics.columnsFor(1920), 5);
    });

    test('card height stays positive and caps the image area', () {
      final phone = ProductGridMetrics.of(320);
      final wide = ProductGridMetrics.of(1920);

      expect(phone.mainAxisExtent, greaterThan(200));
      expect(wide.mainAxisExtent, lessThanOrEqualTo(210 + 124));
      expect(wide.spacing, greaterThan(phone.spacing));
    });
  });

  group('ResponsiveProductGrid', () {
    Future<void> pumpAt(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ResponsiveProductGrid(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 12,
                itemBuilder: tile,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders phone layouts without overflow', (tester) async {
      for (final size in const [
        Size(320, 568),
        Size(360, 800),
        Size(430, 932),
      ]) {
        await pumpAt(tester, size);
        expect(tester.takeException(), isNull, reason: '$size');
        expect(find.byKey(const ValueKey('tile-0')), findsOneWidget);
      }
    });

    testWidgets('renders tablet and desktop layouts without overflow', (
      tester,
    ) async {
      for (final size in const [
        Size(768, 1024),
        Size(1024, 1366),
        Size(1440, 900),
      ]) {
        await pumpAt(tester, size);
        expect(tester.takeException(), isNull, reason: '$size');
      }
    });
  });
}
