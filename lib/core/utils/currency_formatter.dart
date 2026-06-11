import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _usd = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  static final _usdDecimal = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _compact = NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 1);

  static String format(double amount, {bool compact = false, bool showCents = false}) {
    if (compact) return _compact.format(amount);
    if (showCents) return _usdDecimal.format(amount);
    return _usd.format(amount);
  }

  static String formatCompact(double amount) => _compact.format(amount);

  static String formatWithCents(double amount) => _usdDecimal.format(amount);

  /// Returns just the number portion without currency symbol.
  static String formatNumber(double amount) =>
      NumberFormat('#,###', 'en_US').format(amount);
}
