import 'package:intl/intl.dart';

/// Centralized Philippine peso formatting.
///
/// Money is stored everywhere as integer centavos (1 peso = 100 centavos).
/// Only this file decides how it is rendered, so the currency can never drift
/// between screens.
const String kCurrencySymbol = '₱';

final NumberFormat _currency = NumberFormat.currency(
  locale: 'en_PH',
  symbol: kCurrencySymbol,
  decimalDigits: 2,
);

final NumberFormat _currencyWhole = NumberFormat.currency(
  locale: 'en_PH',
  symbol: kCurrencySymbol,
  decimalDigits: 0,
);

/// Formats integer centavos as Philippine pesos, e.g. `₱5,990.00`.
///
/// Pass [showCents] as `false` for compact catalog prices; whole-peso amounts
/// render as `₱5,990` while amounts with centavos keep two decimals.
String formatMoney(int cents, {bool showCents = true}) {
  if (!showCents && cents % 100 == 0) {
    return _currencyWhole.format(cents / 100);
  }
  return _currency.format(cents / 100);
}

String formatCompactCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
  }
  if (value >= 1000) {
    final digits = value % 1000 == 0 ? 0 : 1;
    return '${(value / 1000).toStringAsFixed(digits)}K';
  }
  return '$value';
}

String formatShortDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

String formatTime(DateTime date) => DateFormat('h:mm a').format(date);

String formatDateTime(DateTime date) =>
    '${DateFormat('MMM d, yyyy').format(date)}, ${DateFormat('h:mm a').format(date)}';

String formatCardNumber(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length <= 4) return '•••• $digits';
  return '•••• ${digits.substring(digits.length - 4)}';
}
