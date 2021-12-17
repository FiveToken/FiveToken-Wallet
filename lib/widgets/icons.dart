// import 'package:fil/index.dart';
import 'package:flutter/material.dart';
import 'package:fil/widgets/style.dart';

class CoinIcon {
  Color bg;
  bool border;
  Widget icon;
  CoinIcon({this.bg, this.border = false, this.icon});
  static Map<String, CoinIcon> get icons {
    return {
      'FIL': CoinIcon(
          bg: CustomColor.primary,
          icon: Image(
            image: AssetImage('icons/fil-w.png'),
          ),
          border: false),
      'ETH': CoinIcon(
          bg: Colors.transparent,
          icon: Image(
            image: AssetImage('icons/eth.png'),
          ),
          border: false),
      'BNB': CoinIcon(
          bg: Colors.transparent,
          icon: Image(
            image: AssetImage('icons/bnb.png'),
          ),
          border: false)
    };
  }
}
