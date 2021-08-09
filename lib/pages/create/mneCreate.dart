import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:fil/pages/create/warn.dart';

class MneCreatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MneCreatePageState();
  }
}

class MneCreatePageState extends State<MneCreatePage> {
  String mne;
  @override
  void initState() {
    super.initState();
    genMne();
    Future.delayed(Duration.zero).then((value) {
      showCustomDialog(
          context,
          Column(
            children: [
              CommonTitle('cut'.tr,showDelete: true,),
              Container(
                child: Text(
                  'shareCut'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                padding: EdgeInsets.symmetric(horizontal: 57, vertical: 28),
              ),
              Divider(
                height: 1,
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: CommonText(
                    'know'.tr,
                    color: CustomColor.primary,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8),
                ),
                onTap: () {
                  Get.back();
                },
              ),
            ],
          ));
    });
  }

  void genMne() {
    setState(() {
      mne = bip39.generateMnemonic(lang: 'en');
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      footerText: 'next'.tr,
      onPressed: () {
        Get.toNamed(mneCheckPage, arguments: {"mne": mne});
      },
      grey: true,
      body: Padding(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    'backupMne'.tr,
                    size: 14,
                    weight: FontWeight.w500,
                  ),
                  GestureDetector(
                    child: CommonText(
                      'writeMne'.tr,
                      size: 14,
                      color: Color(0xffB4B5B7),
                    ),
                    onTap: () {
                      copyText(mne);
                      showCustomToast('copyMne'.tr);
                    },
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: mneGrids(),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Column(
                children: [
                  TipItem('placeMne'.tr),
                  TipItem('shareMne'.tr),
                ],
              ),
              padding: EdgeInsets.only(right: 12),
            )
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget mneGrids() {
    List mneList = mne.split(' ');
    if (mneList.length != 12) {
      return SizedBox();
    }
    var itemList = mneList.asMap().entries.map((entry) {
      var v = entry.value;
      return MneItem(
        label: v,
        index: (entry.key + 1).toString() + '.',
      );
    }).toList();

    return GridView.count(
        padding: const EdgeInsets.all(12),
        physics: NeverScrollableScrollPhysics(),
        childAspectRatio: 2.1,
        crossAxisSpacing: 20,
        mainAxisSpacing: 12,
        crossAxisCount: 3,
        shrinkWrap: true,
        children: itemList);
  }
}

class MneItem extends StatelessWidget {
  final String label;
  final Noop onTap;
  final String index;
  final Color bg;
  final bool remove;
  MneItem(
      {this.label, this.onTap, this.index = '', this.bg, this.remove = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      child: Stack(
        children: [
          Positioned(
              child: Container(
            decoration: BoxDecoration(
                color: bg ?? Color(0xFF5C8BCB), borderRadius: CustomRadius.b8),
            alignment: Alignment.center,
            child: CommonText(
              label,
              size: 14,
              color: Colors.white,
            ),
          )),
          Positioned(
              child: Visibility(
                  visible: index != '',
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: CommonText(
                      index,
                      size: 10,
                      color: Colors.white,
                    ),
                  ))),
          Positioned(
              right: 5,
              top: 5,
              child: Visibility(
                  visible: remove,
                  child: Image(
                    width: 13,
                    image: AssetImage('icons/close.png'),
                  )))
        ],
      ),
    );
  }
}
