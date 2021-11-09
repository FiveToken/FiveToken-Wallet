import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectLangPage extends StatelessWidget {
  void selectLang(String lang,context) async {
    Locale l = Locale(lang);
    Get.updateLocale(l);
    Global.langCode = lang;
    Global.store.setString(StoreKeyLanguage, lang);
    Get.toNamed(initWalletPage);
    BlocProvider.of<MainBloc>(context).add(AppOpenEvent(count: 1));
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
                            selectLang('en',context);
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
                            selectLang('kr',context);
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
                            selectLang('jp',context);
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
                            selectLang('zh',context);
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
