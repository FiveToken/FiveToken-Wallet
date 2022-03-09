import 'dart:convert';
import 'dart:typed_data';

import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:fil/utils/num_extension.dart';

extension DecimalExtension on Decimal {
  String fmtDown(int decimals) {
    if (!isInteger && decimals < scale) {
      final _integer = List.generate(20, (index) => '#').join('');
      final _decimal = List.generate(decimals, (index) => '#').join('');
      final fmtString = _integer + '.' + _decimal;
      final _numberFormat = NumberFormat(fmtString);
      return _numberFormat.format(toDouble().roundDown(decimals));
    }
    return toString();
  }

  String fmtUp(int decimals) {
    if (!isInteger && decimals <= scale) {
      final _integer = List.generate(20, (index) => '#').join('');
      final _decimal = List.generate(decimals, (index) => '#').join('');
      final fmtString = _integer + '.' + _decimal;
      final _numberFormat = NumberFormat(fmtString);
      return _numberFormat.format(toDouble().roundDown(decimals));
    }
    return toString();
  }
}

extension Uint8ListExtension on Uint8List{
  String toEncode(){
    return base64Encode(this);
  }
}
