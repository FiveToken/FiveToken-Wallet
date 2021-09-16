import 'package:fil/index.dart';

/// show the importance of mne
class CreateWarnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      grey: true,
      title: 'createWallet'.tr,
      footerText: 'next'.tr,
      onPressed: () {
        Get.toNamed(mnePage);
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Image(width: 86, image: AssetImage('icons/wallet.png')),
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(0, 38, 0, 25),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: Colors.white),
            margin: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: CustomColor.primary,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8))),
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 11),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        'warn'.tr,
                        size: 14,
                        color: Colors.white,
                        weight: FontWeight.w500,
                      ),
                      // CommonText(
                      //   'missMne'.tr,
                      //   size: 8,
                      //   color: Colors.white,
                      // )
                    ],
                  ),
                ),
                SizedBox(
                  height: 17,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 0, 14, 0),
                  child: Column(
                    children: [
                      TipItem('tip1'.tr),
                      TipItem('tip2'.tr),
                      TipItem('tip3'.tr)
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class TipItem extends StatelessWidget {
  final String tip;
  TipItem(this.tip);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image(width: 24, image: AssetImage('icons/warn.png')),
          SizedBox(
            width: 12,
          ),
          Expanded(
              child: CommonText(
            tip,
            size: 14,
            weight: FontWeight.w500,
          ))
        ],
      ),
    );
  }
}
