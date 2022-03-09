import 'dart:ui';
import 'package:flutter/material.dart';

class StrengthPassword extends CustomPainter {
  final num level;
  final BuildContext context;
  StrengthPassword({this.level = 0, this.context});
  Paint _active = new Paint()
    ..color = Colors.cyan
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke;

  Paint _inactive = new Paint()
    ..color = Colors.grey
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size){
    var list = [0,1,2,3];
    var width =  (MediaQuery.of(context).size.width - 20 *3) /4;
    list.forEach((element) {
      var _paint = this.level > element ? _active: _inactive;
      var offsetX1 = (element*width).toDouble();
      var offsetX2 = ((element+1)*width+10).toDouble();
      canvas.drawLine(Offset(element > 0 ? offsetX1+20:offsetX1+20,16), Offset(offsetX2, 16),  _paint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
