import 'package:fil/index.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
/// display qrcode of the wallet address
class WalletCodePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var addr = singleStoreController.wal.addr;
    return CommonScaffold(
      title: 'rec'.tr,
      hasFooter: false,
      barColor: CustomColor.primary,
      titleColor: Colors.white,
      background: CustomColor.primary,
      leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: Image(
          width: 20,
          image: AssetImage("icons/back-w.png"),
        ),
        alignment: NavLeadingAlign,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(25, 20, 25, 0),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Container(
                    child: Text(
                      'scan'.tr,
                      style: TextStyle(
                        color: CustomColor.grey
                      ),
                      textAlign: TextAlign.center,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 25),
                  ),
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('icons/border.png'))),
                    child: QrImage(
                      data: addr,
                      size: 188,
                      backgroundColor: Colors.white,
                      version: QrVersions.auto,
                    ),
                  ),
                  Container(
                      child: Text(
                        addr,
                        style: TextStyle(color: CustomColor.grey, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 34, vertical: 25)),
                  Container(
                    decoration: BoxDecoration(
                        color: CustomColor.bgGrey,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        )),
                    padding: EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                    width: 20,
                                    image: AssetImage('icons/copy.png')),
                                CommonText(
                                  'copy'.tr,
                                )
                              ],
                            ),
                            onTap: () {
                              copyText(addr);
                              showCustomToast('copyAddr'.tr);
                            },
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 17,
                          color: CustomColor.grey,
                        ),
                        Expanded(
                          child: GestureDetector(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                    width: 20,
                                    image: AssetImage('icons/share-d.png')),
                                CommonText(
                                  'share'.tr,
                                )
                              ],
                            ),
                            onTap: () {
                              Share.share(addr);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(width: 25, image: AssetImage('icons/fil2.png')),
                  SizedBox(
                    width: 10,
                  ),
                  CommonText(
                    'Filecoin Wallet',
                    color: Colors.white,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
