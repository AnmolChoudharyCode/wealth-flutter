import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final _compact = NumberFormat.compactCurrency(symbol: '₹');
  static final _full = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
  static final _noDecimal = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  /// Format large amounts compactly: ₹1.2M, ₹345.6K
  static String compact(double value) => _compact.format(value);

  /// Format with full precision: ₹1,234.56
  static String full(double value) => _full.format(value);

  /// Format without decimals: ₹1,234
  static String noDecimal(double value) => _noDecimal.format(value);

  /// Format with sign for P&L: +₹1,234.56 or -₹234.56
  static String pnl(double value) {
    final formatted = _full.format(value.abs());
    return value >= 0 ? '+$formatted' : '-$formatted';
  }
}
