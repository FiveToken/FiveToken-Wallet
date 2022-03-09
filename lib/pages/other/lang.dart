import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/common/global.dart';

class LangPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LangPageState();
  }
}
// Page of Language selection
class LangPageState extends State<LangPage> {
  // Set language
  void selectLang(String lang) async {
    Locale locale = Locale(lang);
    Global.store.setString(StoreKeyLanguage, lang);
    Get.updateLocale(locale);
    Global.langCode = lang;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'lang'.tr,
      hasFooter: false,
      grey: true,
      body: Padding(
        child: Column(
          children: [
            TapItemCard(
              items: [
                CardItem(
                  label: 'English',
                  onTap: () => selectLang('en'),
                ),
                CardItem(
                  label: '한국어',
                  onTap: () => selectLang('kr'),
                ),
                CardItem(
                  label: '日本語',
                  onTap: () => selectLang('jp'),
                ),
                CardItem(
                  label: '中文',
                  onTap: () => selectLang('zh'),
                ),
              ],
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      ),
    );
  }
}
