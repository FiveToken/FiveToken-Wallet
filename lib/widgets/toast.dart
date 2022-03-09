import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/style.dart';

class ToastContent extends StatelessWidget {
  final Widget body;
  ToastContent(this.body);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Transform.translate(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Color.fromARGB(30, 0, 0, 0),
                    offset: Offset(-1, 5),
                    blurRadius: 20)
              ], color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: SingleChildScrollView(
                child: body,
              ),
            ),
            offset: Offset(0, -100)));
  }
}

void showCustomToast(String title, {Widget icon}) {
  var future = showToastWidget(ToastContent(Column(
    children: [
      CommonText(
        title,
        size: 14,
        color: CustomColor.primary,
        weight: FontWeight.w500,
      ),
      icon ??
          Image(
            width: 30,
            image: AssetImage('icons/succ.png'),
          )
    ],
  )));
  Future.delayed(Duration(seconds: 2)).then((value) {
    future.dismiss();
  });
}

ToastFuture showCustomLoading(String title) {
  return showToastWidget(ToastContent(Column(
    children: [
      CommonText(
        title,
        size: 14,
        color: CustomColor.primary,
        weight: FontWeight.w500,
      ),
      SizedBox(
        height: 5,
      ),
      CupertinoActivityIndicator()
    ],
  )));
}

void showCustomError(String title) {
  var future = showToastWidget(ToastContent(Column(
    children: [
      CommonText(
        title,
        size: 14,
        color: CustomColor.red,
        weight: FontWeight.w500,
      ),
      SizedBox(
        height: 5,
      ),
      Image(
        width: 30,
        image: AssetImage('icons/close-r.png'),
      )
    ],
  )));
  Future.delayed(Duration(seconds: 2)).then((value) {
    future.dismiss();
  });
}
