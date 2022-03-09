import 'package:fil/chain/net.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:fil/common/utils.dart';
import 'package:flutter/material.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/toast.dart';
import 'package:get/get.dart';
import 'package:fil/routes/path.dart';
import 'package:flutter/services.dart';
import 'package:fil/pages/other/scan.dart';


class ImportMnePage extends StatefulWidget {
  @override
  State createState() => ImportMnePageState();
}
// Pages of import Mnemonic words
class ImportMnePageState extends State<ImportMnePage> {
  TextEditingController inputControl = TextEditingController(); // input of Mnemonic
  TextEditingController nameControl = TextEditingController(); // input of wallet Name
  Network net = Get.arguments['net'] as Network;
  int type = Get.arguments['type'] as int;
  // Validate from Mnemonic, wallet name
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
    } else if(label.length>20) {
      showCustomError('placeholderWalletName'.tr);
      return false;
    } else {}

    String mneFilter =  StringTrim(inputStr);
    if (!bip39.validateMnemonic(
      mneFilter,
    )) {
      showCustomError('wrongMne'.tr);
      return false;
    }
    return true;
  }

  // Import mnemonics
  void handleImport() async {
    String inputStr = inputControl.text.trim();
    String label = nameControl.text.trim();
    Get.toNamed(passwordSetPage,
        arguments: {'net': net, 'type': type, 'label': label, 'mne': inputStr});
  }

  // Import mnemonics by scanning
  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Mne}).then((value) {
      try {
        inputControl.text = value as  String;
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
                      hintText: 'placeholderMne'.tr,
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
                placeholder: 'placeholderWalletName'.tr,
                maxLength: 20,
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
