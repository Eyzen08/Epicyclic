import 'package:intl/intl.dart';

final NumberFormat _currency = NumberFormat.currency(
  locale: 'en_US',
  symbol: r'$',
  decimalDigits: 2,
);

String formatMoney(int cents, {bool showCents = true}) {
  if (!showCents && cents % 100 == 0) {
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: r'$',
      decimalDigits: 0,
    ).format(cents / 100);
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
