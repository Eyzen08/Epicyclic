import 'package:epicyclic/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatMoney (Philippine peso)', () {
    test('renders two decimals for exact catalog amounts', () {
      expect(formatMoney(599000), '₱5,990.00');
      expect(formatMoney(129900), '₱1,299.00');
      expect(formatMoney(139500), '₱1,395.00');
      expect(formatMoney(1199500), '₱11,995.00');
    });

    test('drops cents only when asked and the amount is whole pesos', () {
      expect(formatMoney(599000, showCents: false), '₱5,990');
      expect(formatMoney(139500, showCents: false), '₱1,395');
      expect(formatMoney(139550, showCents: false), '₱1,395.50');
    });

    test('never renders a dollar sign', () {
      for (final cents in [0, 1, 9900, 599000, 1234567]) {
        expect(formatMoney(cents), isNot(contains(r'$')));
      }
    });

    test('handles zero and small amounts', () {
      expect(formatMoney(0), '₱0.00');
      expect(formatMoney(250), '₱2.50');
    });
  });

  group('formatCompactCount', () {
    test('compacts thousands and millions', () {
      expect(formatCompactCount(999), '999');
      expect(formatCompactCount(1000), '1K');
      expect(formatCompactCount(1200), '1.2K');
      expect(formatCompactCount(1000000), '1M');
    });
  });
}
