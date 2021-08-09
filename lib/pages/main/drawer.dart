import 'package:fil/index.dart';
import 'package:share/share.dart';

class DrawerBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var label = $store.wal.label;
    var addr = $store.wal.addr;
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
          ),
          GestureDetector(
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                ),
                CommonText(
                  label,
                  size: 18,
                  weight: FontWeight.w500,
                ),
                SizedBox(
                  width: 10,
                ),
                Image(width: 20, image: AssetImage('icons/switch.png'))
              ],
            ),
            onTap: () {
              Get.back();
              Get.toNamed(walletSelectPage);
            },
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            margin: EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
                color: CustomColor.bgGrey,
                borderRadius: BorderRadius.circular(5)),
            child: CommonText(
              dotString(str: addr),
              color: CustomColor.grey,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(thickness: .2),
          DrawerItem(
            onTap: () {
              // Get.back();
              //Get.toNamed(initWalletPage);
              Get.toNamed(passwordSetPage);
            },
            label: 'wallet'.tr,
            iconPath: 'wal.png',
          ),
          DrawerItem(
            onTap: () {
              openInBrowser(
                  'https://filscan.io/tipset/address-detail?address=$addr');
            },
            label: 'filscan'.tr,
            iconPath: 'broswer.png',
          ),
          Divider(thickness: .2),
          DrawerItem(
            onTap: () {
              Share.share(addr);
            },
            label: 'shareAddr'.tr,
            iconPath: 'share.png',
          ),
          DrawerItem(
            onTap: () {
              Get.toNamed(setPage);
            },
            label: 'set'.tr,
            iconPath: 'setting.png',
          ),
          DrawerItem(
            onTap: () {
              var url = Global.langCode == 'zh'
                  ? 'https://docs.google.com/forms/d/e/1FAIpQLSeZrn_8u6GUHlQQRZdvwRUrhCNOCiopVe1_z9alvOiyQFJW5A/viewform?usp=sf_link'
                  : 'https://docs.google.com/forms/d/e/1FAIpQLSfXRxdhK8NPcMxrHtDNpocFGZ5sFpINmcurYes-5x2c80aAdQ/viewform?usp=sf_link';
              openInBrowser(url);
            },
            label: 'feedback'.tr,
            iconPath: 'feedback.png',
          ),
          Divider(thickness: .2),
          DrawerItem(
            onTap: () {
              openInBrowser('https://twitter.com/FilecoinWallet');
            },
            label: 'Twitter',
            iconPath: 'twitter.png',
          ),
          DrawerItem(
            onTap: () {
              openInBrowser('https://filecoinwalletdeveloper.medium.com/');
            },
            label: 'Medium',
            iconPath: 'medium.png',
          ),
          DrawerItem(
            onTap: () {
              openInBrowser('https://app.slack.com/client/TEHTVS1L6/CPFTWMY7N');
            },
            label: 'Slack',
            iconPath: 'slack.png',
          ),
          DrawerItem(
            onTap: () {
              openInBrowser('https://t.me/filecoin');
            },
            label: 'Telegram',
            iconPath: 'telegram.png',
          ),
          Divider(thickness: .2),
          Spacer(),
          Container(
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                ),
                Image(
                  width: 25,
                  image: AssetImage('icons/fivetoken.png'),
                ),
                SizedBox(
                  width: 10,
                ),
                CommonText(
                  'FiveToken',
                  size: 14,
                  weight: FontWeight.w500,
                  color: CustomColor.primary,
                )
              ],
            ),
          ),
          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final Noop onTap;
  final String label;
  final String iconPath;
  DrawerItem(
      {@required this.onTap, @required this.label, @required this.iconPath});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.back();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            Image(width: 20, image: AssetImage('icons/$iconPath')),
            SizedBox(
              width: 25,
            ),
            CommonText(
              label,
              size: 14,
              weight: FontWeight.w500,
            )
          ],
        ),
      ),
    );
  }
}
