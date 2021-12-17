import 'package:decimal/decimal.dart';

extension StringExtension on String {
  Decimal get toDecimal => Decimal.parse(this);
}
