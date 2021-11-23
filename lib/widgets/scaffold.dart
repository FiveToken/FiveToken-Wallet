// import 'package:fil/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/index.dart';

typedef dynamic OnPress();
typedef dynamic OBack();

class CommonScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  final String footerText;
  final OnPress onPressed;
  final bool hasFooter;
  final Color background;
  final Color barColor;
  final Color titleColor;
  final bool hasLeading;
  final bool grey;
  final bool resizeToAvoidBottomInset;
  final Widget leading;
  final Widget footer;
  final OBack backFn;
  CommonScaffold(
      {this.title = '',
      this.body,
      this.actions = const <Widget>[],
      this.footerText = '',
      this.onPressed,
      this.background,
      this.barColor,
      this.titleColor,
      this.hasLeading = true,
      this.grey = false,
      this.leading,
      this.footer,
      this.resizeToAvoidBottomInset = false,
      this.hasFooter = true,
        this.backFn
      });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            this.background ?? (grey ? Color(0xfff8f8f8) : Colors.white),
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: PreferredSize(
          child: AppBar(
            backgroundColor:
                barColor ?? (grey ? Color(0xfff8f8f8) : Colors.white),
            elevation: 0,
            title: CommonText(
              title,
              color: titleColor ?? Colors.black,
              weight: FontWeight.w500,
              size: 18,
            ),
            leading: leading ??
                Visibility(
                  child: IconButton(
                    onPressed: () {
                      if(this.backFn != null){
                        this.backFn();
                      }else{
                        Get.back();
                      }
                    },
                    icon: IconNavBack,
                    alignment: NavLeadingAlign,
                  ),
                  visible: hasLeading,
                ),
            centerTitle: true,
            actions: actions,
          ),
          preferredSize: Size.fromHeight(NavHeight),
        ),
        body: body,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: hasFooter
            ? footer ??
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(const Radius.circular(8)),
                    color: CustomColor.primary,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  child: FlatButton(
                    child: Text(
                      footerText,
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      onPressed();
                    },
                    //color: Colors.blue,
                  ),
                )
            : Container());
  }
}
