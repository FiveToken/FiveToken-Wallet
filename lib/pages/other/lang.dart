import 'package:fil/index.dart';
/// language set page
class LangPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LangPageState();
  }
}

class LangPageState extends State<LangPage> {
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
            TabCard(
              items: [
                CardItem(
                  label: 'English',
                  onTap: () {
                    selectLang('en');
                  },
                ),
                CardItem(
                  label: '한국어',
                  onTap: () {
                    selectLang('kr');
                  },
                ),
                CardItem(
                  label: '日本語',
                  onTap: () {
                    selectLang('jp');
                  },
                ),
                CardItem(
                  label: '中文',
                  onTap: () {
                    selectLang('zh');
                  },
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
