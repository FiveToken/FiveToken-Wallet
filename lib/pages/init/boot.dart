import 'package:fil/index.dart';

class BootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BootPageState();
  }
}

class BootPageState extends State<BootPage> {
  @override
  void initState() {
    super.initState();
    var nextRoute = mainPage;
    if (Global.activeWallet == null) {
      nextRoute = initLangPage;
    }
    Future.delayed(Duration(seconds: 2)).then((value) {
      Get.toNamed(nextRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Container(
          child: CommonText(
            'welcome'.tr,
            size: 12,
            color: Colors.transparent,
            weight: FontWeight.w300,
          ),
          padding: EdgeInsets.only(bottom: 40),
        ),
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover, image: AssetImage('icons/bg.png'))),
      ),
    );
  }
}
