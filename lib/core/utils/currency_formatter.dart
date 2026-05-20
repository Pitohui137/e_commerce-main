import 'package:intl/intl.dart';

/// Format dan konversi mata uang untuk e-commerce Indonesia.
abstract final class CurrencyFormatter {
  /// FakeStore API mengembalikan harga dalam USD.
  static const double usdToIdrRate = 16000;

  static final NumberFormat _idr = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String format(double amount) => _idr.format(amount);

  static double usdToIdr(double usd) => usd * usdToIdrRate;
}
