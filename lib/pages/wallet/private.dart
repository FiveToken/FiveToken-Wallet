import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';
/// display private key of the wallet
class WalletPrivatekeyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletPrivatekeyPageState();
  }
}

class WalletPrivatekeyPageState extends State<WalletPrivatekeyPage> {
  int index = 0;
  bool showCode = false;
  String private = Get.arguments['private'] as String;
  ChainWallet wallet = Get.arguments['wallet'] as ChainWallet;
  @override
  Widget build(BuildContext context) {
    var ck = wallet.addressType == 'eth'
        ? private
        : base64ToHex(private, wallet.address[1]);
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
