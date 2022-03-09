import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/index.dart';
import 'package:fil/common/global.dart';


class SelectLangPage extends StatelessWidget {
  void selectLang(String lang, BuildContext context) async {
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
                          onTap: () => selectLang('en',context)
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TapItemCard(
                    items: [
                      CardItem(
                          label: '한국어',
                          onTap: () => selectLang('kr',context)
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TapItemCard(
                    items: [
                      CardItem(
                          label: '日本語',
                          onTap: () => selectLang('jp',context),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TapItemCard(
                    items: [
                      CardItem(
                          label: '中文',
                          onTap: () => selectLang('zh',context)
                      )
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
