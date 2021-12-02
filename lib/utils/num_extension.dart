import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:fil/utils/string_extension.dart';

extension NumExtension on num {
  double floor(num step) {
    if (this == null || isNaN || isInfinite) {
      return 0.0;
    }
    return ((toDecimal ~/ step.toDecimal).toString().toDecimal * step.toDecimal)
        .toDouble();
  }

  double roundDown(int decimals) {
    final step = double.tryParse(pow(10, -decimals).toStringAsFixed(decimals));
    return floor(step);
  }

  double roundUp(int decimals) {
    final step = double.tryParse(pow(10, -decimals).toStringAsFixed(decimals));
    return ceil(step);
  }

  double ceil(num step) {
    if (this == null || isNaN || isInfinite || step == null) {
      return 0.0;
    }
    return (((this ~/ step) + 1) * step)?.toDouble() ?? 0.0;
  }

  Decimal get toDecimal => Decimal.parse(toString());
}
