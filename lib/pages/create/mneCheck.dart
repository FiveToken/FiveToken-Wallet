import 'package:fil/chain/wallet.dart';
import 'package:fil/common/index.dart';
import 'package:fil/index.dart';

class MneCheckPage extends StatefulWidget {
  @override
  State createState() => MneCheckPageState();
}

class MneCheckPageState extends State<MneCheckPage> {
  List<String> unSelectedList = [];
  List<String> selectedList = [];
  final String mne = Get.arguments['mne'] as String;
  @override
  void initState() {
    super.initState();
    var list = mne.split(' ');
    print(mne);
    list.shuffle();
    unSelectedList = list;
  }

  void handleSelect(num index) {
    var rm = unSelectedList.removeAt(index);
    selectedList.add(rm);
    setState(() {});
  }

  void handleRemove(num index) {
    var rm = selectedList.removeAt(index);
    unSelectedList.add(rm);
    setState(() {});
  }

  String get mneCk {
    return genCKBase64(mne);
  }

  void createWallet(BuildContext context, String type) async {
    // var pk = EthWallet.genPrivateKeyByMne(mne);
    // var addr = await EthWallet.genAddrByPrivateKey(pk);

    // try {
    //   String signType = SignSecp;
    //   String pk = '';
    //   String ck = '';
    //   if (type == '1') {
    //     ck = genCKBase64(mne);
    //     pk = await Flotus.secpPrivateToPublic(ck: ck);
    //   } else {
    //     var key = bip39.mnemonicToSeed(mne);
    //     signType = SignBls;
    //     ck = await Bls.ckgen(num: key.join(""));
    //     pk = await Bls.pkgen(num: ck);
    //   }
    //   String address = await Flotus.genAddress(pk: pk, t: signType);
    //   address = Global.netPrefix + address.substring(1);
    //   var exist = OpenedBox.addressInsance.containsKey(address);
    //   if (exist) {
    //     showCustomError('errorExist'.tr);
    //     return;
    //   }
    //   Wallet wallet = Wallet(
    //       ck: ck,
    //       address: address,
    //       label: 'FIL',
    //       walletType: 0,
    //       mne: mne,
    //       type: type);
    //   Get.toNamed(passwordSetPage,
    //       arguments: {'wallet': wallet, 'create': true});
    // } catch (e) {
    //   showCustomError('checkMneFail'.tr);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      grey: true,
      onPressed: () {
        var str = selectedList.join(' ');
        if (str != mne || selectedList.length < 12) {
          showCustomError('wrongMne'.tr);
          return;
        }
        Get.toNamed(passwordSetPage,
            arguments: {'type': 0, 'mne': mne, 'label': 'FIL'});
      },
      footerText: 'next'.tr,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    'checkMne'.tr,
                    size: 14,
                    weight: FontWeight.w500,
                  ),
                  CommonText(
                    'clickMne'.tr,
                    size: 14,
                    color: Color(0xffB4B5B7),
                  ),
                ],
              ),
              width: double.infinity,
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 200),
                child: GridView.count(
                  padding: EdgeInsets.all(10),
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  childAspectRatio: 2.1,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: List.generate(selectedList.length, (index) {
                    return MneItem(
                      remove: true,
                      label: selectedList[index],
                      onTap: () {
                        handleRemove(index);
                      },
                    );
                  }),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GridView.count(
              crossAxisCount: 3,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              childAspectRatio: 2.1,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: List.generate(unSelectedList.length, (index) {
                return MneItem(
                  label: unSelectedList[index],
                  bg: CustomColor.primary,
                  onTap: () {
                    handleSelect(index);
                  },
                );
              }),
            )
          ],
        ),
        padding: EdgeInsets.fromLTRB(12, 20, 12, 100),
      ),
    );
  }
}
