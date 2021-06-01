import 'package:fil/index.dart';

typedef dynamic OnPress();

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
      this.resizeToAvoidBottomInset = false,
      this.hasFooter = true});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            this.background ?? (grey ? Color(0xfff8f8f8) : Color(FColorWhite)),
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: PreferredSize(
          child: AppBar(
            backgroundColor:
                barColor ?? (grey ? Color(0xfff8f8f8) : Color(FColorWhite)),
            elevation: 0,
            title: CommonText(
              title,
              color: titleColor ?? Colors.black,
              weight: FontWeight.w500,
              size: 18,
            ),
            leading: leading??Visibility(
              child: IconButton(
                onPressed: () {
                  Get.back();
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
            ? Container(
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
