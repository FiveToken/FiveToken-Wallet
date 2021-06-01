import 'package:fil/index.dart';

typedef void SelectWalletCb(String type);

class WalletType extends StatefulWidget {
  WalletType({@required this.onChange});
  final SelectWalletCb onChange;
  @override
  State<StatefulWidget> createState() {
    return WalletTypeState();
  }
}

class WalletTypeState extends State<WalletType> {
  String type = '1';
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: CustomRadius.top,
        color: Color(0xfff8f8f8),
      ),
      height: 200,
      child: Column(
        children: [
          CommonTitle('selectAddrType'.tr,showDelete: true,),
          Container(
            child: Column(
              children: [
                TabCard(
                  items: [
                    CardItem(
                        label: 'secp'.tr,
                        onTap: () {
                          Get.back();
                          Global.selectWalletType = '1';
                          widget.onChange('1');
                        })
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                TabCard(
                  items: [
                    CardItem(
                        label: 'bls'.tr,
                        onTap: () {
                          Get.back();
                          Global.selectWalletType = '3';
                          widget.onChange('3');
                        })
                  ],
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(12, 15, 12, 15),
          ),
        ],
      ),
    );
  }
}

void showWalletSelector(BuildContext context, SelectWalletCb cb) {
  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      )),
      builder: (BuildContext context) {
        return WalletType(
          onChange: cb,
        );
      });
}
