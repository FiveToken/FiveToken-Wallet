import 'package:fil/index.dart';

class SelectLangPage extends StatelessWidget {
  void selectLang(String lang) async {
    Locale l = Locale(lang);
    Get.updateLocale(l);
    Global.langCode = lang;
    Global.store.setString(StoreKeyLanguage, lang);
    Get.toNamed(initWalletPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.primary,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    child: ImageFil,
                    padding: EdgeInsets.fromLTRB(0, 40, 0, 12),
                  ),
                  CommonText(
                    'FiveToken',
                    color: Colors.white,
                    size: 20,
                    weight: FontWeight.w800,
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 85, 0, 13),
                    child: CommonText(
                      'selectLang'.tr,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  TapItemCard(
                    items: [
                      CardItem(
                          label: 'English',
                          onTap: () {
                            selectLang('en');
                          })
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TapItemCard(
                    items: [
                      CardItem(
                          label: '한국어',
                          onTap: () {
                            selectLang('kr');
                          })
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TapItemCard(
                    items: [
                      CardItem(
                          label: '日本語',
                          onTap: () {
                            selectLang('jp');
                          })
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TapItemCard(
                    items: [
                      CardItem(
                          label: '中文',
                          onTap: () {
                            selectLang('zh');
                          })
                    ],
                  ),
                ],
              ),
            ),
            Spacer(),
            CommonText(
              Global.version,
              color: Colors.white,
              size: 14,
            ),
            SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
