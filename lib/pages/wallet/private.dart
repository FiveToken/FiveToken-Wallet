import 'package:fil/index.dart';

class WalletPrivatekeyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletPrivatekeyPageState();
  }
}

class WalletPrivatekeyPageState extends State<WalletPrivatekeyPage> {
  int index = 0;
  bool showCode = false;
  String pk = Get.arguments['pk'] as String;
  @override
  Widget build(BuildContext context) {
    var ck = base64ToHex(pk, Global.cacheWallet.type);
    return CommonScaffold(
      title: 'exportPk'.tr,
      grey: true,
      footerText: 'copy'.tr,
      onPressed: () {
        copyText(ck);
        showCustomToast('copySucc'.tr);
      },
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: TabItem(
                active: index == 0,
                label: 'pk'.tr,
                onTap: () {
                  setState(() {
                    index = 0;
                  });
                },
              )),
              Expanded(
                  child: TabItem(
                active: index == 1,
                label: 'code'.tr,
                onTap: () {
                  setState(() {
                    index = 1;
                  });
                },
              )),
            ],
          ),
          index == 0
              ? KeyString(
                  data: ck,
                )
              : KeyCode(
                  data: ck,
                  showCode: showCode,
                  onView: () {
                    setState(() {
                      showCode = true;
                    });
                  },
                )
        ],
      ),
    );
  }
}
