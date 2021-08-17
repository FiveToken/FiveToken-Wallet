import 'package:fil/chain/net.dart';
import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:bip39/bip39.dart' as bip39;

class ImportMnePage extends StatefulWidget {
  @override
  State createState() => ImportMnePageState();
}

class ImportMnePageState extends State<ImportMnePage> {
  TextEditingController inputControl = TextEditingController();
  TextEditingController nameControl = TextEditingController();
  Network net = Get.arguments['net'];
  int type = Get.arguments['type'];
  bool checkValidate() {
    String inputStr = inputControl.text.trim();
    String label = nameControl.text.trim();
    if (inputStr == "") {
      showCustomError('enterMne'.tr);
      return false;
    }
    if (label == "") {
      showCustomError('enterName'.tr);
      return false;
    }
    if (!bip39.validateMnemonic(inputStr,)) {
      showCustomError('wrongMne'.tr);
      return false;
    }
    return true;
  }

  void handleImport() async {
    String inputStr = inputControl.text.trim();
    String label = nameControl.text.trim();

    // String pk = '';
    // String ck = '';
    // String signType = SignSecp;
    // unFocusOf(context);
    // if (type == '1') {
    //   ck = genCKBase64(inputStr);
    //   pk = await Flotus.secpPrivateToPublic(ck: ck);
    // } else {
    //   signType = SignBls;
    //   var key = bip39.mnemonicToSeed(inputStr);
    //   ck = await Bls.ckgen(num: key.join(""));
    //   pk = await Bls.pkgen(num: ck);
    // }
    // String address = await Flotus.genAddress(pk: pk, t: signType);
    // address = Global.netPrefix + address.substring(1);
    // var exist = OpenedBox.addressInsance.containsKey(address);
    // if (exist) {
    //   showCustomError('errorExist'.tr);
    //   return;
    // }
    // Wallet wallet = Wallet(
    //   ck: ck,
    //   address: address,
    //   label: label,
    //   walletType: 0,
    //   type: type,
    //   mne: inputStr,
    // );
    Get.toNamed(passwordSetPage,
        arguments: {'net': net, 'type': type, 'label': label, 'mne': inputStr});
  }

  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Mne}).then((value) {
      try {
        //var ck = aesDecrypt(value, tokenify('filwallet'));
        inputControl.text = value;
      } catch (e) {
        showCustomError('wrongMne'.tr);
      }
    });
  }

  @override
  void dispose() {
    inputControl.dispose();
    nameControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
        grey: true,
        title: 'importMne'.tr,
        footerText: 'import'.tr,
        onPressed: () {
          if (!checkValidate()) {
            return;
          } else {
            handleImport();
            // showWalletSelector(context, (String type) {
            //   handleImport(context, type);
            // });
          }
        },
        actions: [
          Padding(
            child: GestureDetector(
                onTap: handleScan,
                child: Image(
                  width: 20,
                  image: AssetImage('icons/scan.png'),
                )),
            padding: EdgeInsets.only(right: 10),
          )
        ],
        body: Padding(
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    'mne'.tr,
                    weight: FontWeight.w500,
                    size: 14,
                  ),
                  GestureDetector(
                    child: Image(width: 20, image: AssetImage('icons/cop.png')),
                    onTap: () async {
                      var data = await Clipboard.getData(Clipboard.kTextPlain);
                      inputControl.text = data.text;
                    },
                  )
                ],
              ),
              SizedBox(
                height: 13,
              ),
              Container(
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'enterMne'.tr,
                      hintStyle:
                          TextStyle(color: Color(0xffcccccc), fontSize: 14),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none),
                  maxLines: 6,
                  controller: inputControl,
                  autofocus: false,
                ),
                padding: EdgeInsets.only(left: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
              ),
              SizedBox(
                height: 13,
              ),
              Field(
                label: 'walletName'.tr,
                controller: nameControl,
              )
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12,
          ),
        ));
  }
}
