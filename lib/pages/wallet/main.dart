import 'package:fil/index.dart';
import 'package:fil/pages/main/index.dart';
import 'package:fil/pages/wallet/widgets/messageList.dart';

class WalletMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletMainPageState();
  }
}

class WalletMainPageState extends State<WalletMainPage> {
  String price;
  @override
  void initState() {
    super.initState();
    // if (Get.arguments != null && Get.arguments['marketPrice'] != null) {
    //   price = Get.arguments['marketPrice'] as String;
    // }else{
    //   price=singleStoreController.wal.address;
    // }
    price =
        getMarketPrice(singleStoreController.wal.balance, Global.price.rate);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'Filecoin',
      hasFooter: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 25, 0, 17),
            child: Container(
              width: 70,
              height: 70,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: CustomColor.primary,
                  borderRadius: BorderRadius.circular(35)),
              child: Image(
                image: AssetImage('icons/fil-w.png'),
              ),
            ),
            alignment: Alignment.center,
            width: double.infinity,
          ),
          Obx(() => CommonText(
                formatDouble(singleStoreController.wal.balance,
                        truncate: true, size: 8) +
                    ' FIL',
                size: 30,
                weight: FontWeight.w800,
              )),
          CommonText(
            price,
            size: 14,
            color: CustomColor.grey,
          ),
          SizedBox(
            height: 17,
          ),
          WalletService(),
          SizedBox(
            height: 25,
          ),
          Expanded(child: CommonOnlineWallet())
        ],
      ),
    );
  }
}

class WalletService extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            IconBtn(
              onTap: () {
                //Get.toNamed(walletMangePage);
                Get.toNamed(walletCodePage);
              },
              path: 'send.png',
              color: CustomColor.primary,
            ),
            CommonText(
              'rec'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
        SizedBox(
          width: 34,
        ),
        Column(
          children: [
            IconBtn(
              onTap: () {
                Get.toNamed(filTransferPage);
              },
              path: 'rec.png',
              color: Color(0xff5C8BCB),
            ),
            CommonText(
              'send'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
      ],
    );
  }
}

class IconBtn extends StatelessWidget {
  final Noop onTap;
  final String path;
  final Color color;
  final double size;
  IconBtn({this.onTap, this.path, this.color, this.size = 40});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size / 5),
        child: Image(image: AssetImage('icons/$path')),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: color),
      ),
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}

class NoData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        Image(width: 65, image: AssetImage('icons/record.png')),
        SizedBox(
          height: 25,
        ),
        CommonText(
          'noData'.tr,
          color: CustomColor.grey,
        ),
        SizedBox(
          height: 170,
        ),
      ],
    );
  }
}
