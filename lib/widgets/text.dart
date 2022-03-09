import 'package:flutter/material.dart';
import 'package:fil/widgets/style.dart';

class CommonText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  final Color color;
  final TextAlign align;
  final bool ellipsis;
  const CommonText(this.text,
      {this.size = 14, this.weight, this.color = Colors.black, this.align, this.ellipsis});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      textAlign: align ?? TextAlign.start,
      style: TextStyle(fontWeight: weight, color: color, fontSize: size),
    );
  }

  static Widget main(String str, {double size = 14}) {
    return Text(
      str,
      style: TextStyle(
          fontWeight: FontWeight.w500, fontSize: size, color: Colors.black),
    );
  }

  static Widget grey(String str, {double size = 14}) {
    return Text(
      str,
      style: TextStyle(
          fontWeight: FontWeight.w500, fontSize: size, color: CustomColor.grey),
    );
  }

  static Widget center(String str, {double size = 14, Color color}) {
    return Text(
      str,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: size,
          color: color ?? CustomColor.grey),
    );
  }

  static Widget white(String str,
      {double size = 14, FontWeight weight = FontWeight.w500}) {
    return Text(
      str,
      style: TextStyle(fontWeight: weight, fontSize: size, color: Colors.white),
    );
  }
}

class BoldText extends CommonText {
  BoldText(String text, {double size, Color color})
      : super(text, weight: FontWeight.w600, size: size, color: color);
}
