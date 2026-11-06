import 'package:epicyclic/core/theme/app_theme.dart';
import 'package:epicyclic/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in <double>[320, 390]) {
    testWidgets(
      'compact hero keeps its copy clear of the artwork at ${width.toInt()} px',
      (tester) async {
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(
              body: Padding(padding: EdgeInsets.all(20), child: HeroCarousel()),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 400));

        final title = tester.getRect(find.text('Level Up\nYour Setup'));
        final artwork = tester.getRect(find.byType(Image).first);

        expect(
          title.right,
          lessThanOrEqualTo(artwork.left),
          reason: 'hero copy must stay in the text panel, not over the photo',
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
