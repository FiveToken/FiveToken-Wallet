import 'dart:math';
import 'package:fil/common/utils.dart';

class Fil {
  String attofil;

  double _fil(){
    var n = BigInt.parse(attofil);
    var p = BigInt.from(10);
    p = p.pow(18);
    
    return (n / p);
  }

  double toDouble() {
    return _fil();
  }

  bool isUnitFil() {
    return attofil.length > 9;
  }

  String toStringWithUnit() {
    if(attofil.length < 9) {
      return "$attofil AttoFil";
    }
    return toFixed(len: 8);
  }

  String toString() {
    double v = _fil();
    return v.toString();
  }

  String toFixed({int len = 12}) {
    double v = _fil();
    if(v == 0){
      return "0";
    }
    var r = v.toStringAsFixed(len).replaceFirst(RegExp(r"0+$"), "");
    r = r.replaceFirst(RegExp(r"\.$"), "");
    return parseE(r);
  }

  Fil({String attofil}) {
    this.attofil = attofil;
  }

  Fil.fromDouble(double n) {
    var s = (n * pow(10, 18)).toString();
    s = s.replaceFirst(RegExp(r"0+$"), "");
    s = s.replaceFirst(RegExp(r"\.$"), "");
    this.attofil = s;
  }
}
