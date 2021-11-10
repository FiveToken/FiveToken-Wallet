import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
// import 'package:fil/index.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/models/index.dart';
import 'package:flutter/services.dart';
import 'package:fil/common/utils.dart';


class ImportPrivateKeyPage extends StatefulWidget {
  @override
  State createState() => ImportPrivateKeyPageState();
}

class ImportPrivateKeyPageState extends State<ImportPrivateKeyPage> {
  TextEditingController inputControl = TextEditingController();
  TextEditingController nameControl = TextEditingController();
  Network net = Get.arguments['net'];
  void _handleImport(BuildContext context) async {
    var inputStr = inputControl.text.trim();
    var name = nameControl.text;
    if (inputStr == "") {
      showCustomError('enterPk'.tr);
      return;
    }
    if (inputStr.startsWith('0x')) {
      inputStr = inputStr.substring(2);
    }
    if (name == '') {
      showCustomError('enterName'.tr);
      return;
    }
    if (net.chain == 'filecoin') {
      try {
        PrivateKey.fromMap(jsonDecode(hex2str(inputStr)));
      } catch (e) {
        showCustomError('wrongPk'.tr);
        return;
      }
    } else {
      try {
        await EthWallet.genAddrByPrivateKey(inputStr);
      } catch (e) {
        showCustomError('wrongPk'.tr);
        return;
      }
    }
    Get.toNamed(passwordSetPage, arguments: {
      'type': 2,
      'privateKey': inputStr,
      'net': net,
      'label': name
    });
  }

  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.PrivateKey})
        .then((value) {
      try {
        inputControl.text = value;
      } catch (e) {
        showCustomError('wrongPk'.tr);
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
        title: 'importPk'.tr,
        footerText: 'import'.tr,
        onPressed: () {
          _handleImport(context);
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
                    'pk'.tr,
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
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none),
                  maxLines: 6,
                  controller: inputControl,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    _handleImport(context);
                  },
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
