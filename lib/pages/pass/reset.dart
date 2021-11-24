import 'package:fil/chain/key.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/models/wallet.dart';
// import 'package:fil/index.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/store/store.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/pages/pass/init.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/chain/net.dart';

class PassResetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PassResetPageState();
  }
}

class PassResetPageState extends State<PassResetPage> {
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController newCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();
  var box = OpenedBox.get<ChainWallet>();
  bool loading = false;
  ChainWallet wallet = Get.arguments['wallet'];

  Future<EncryptKey> getKey(String addressType, String privateKey,  String pass, String prefix) async{
    EncryptKey key;
    switch(addressType){
      case 'eth':
        key = await EthWallet.genEncryptKeyByPrivateKey(privateKey, pass);
        break;
      default:
        key = await FilecoinWallet.genEncryptKeyByPrivateKey(privateKey, pass,  prefix: prefix);
        break;
    }
    return key;
  }

  void handleConfrim() async {
    try {
      var pass = passCtrl.text.trim();
      var newPass = newCtrl.text.trim();
      var confirmPass = confirmCtrl.text.trim();
      if (pass == '') {
        showCustomError('enterOldPass'.tr);
        return;
      }
      if(newPass==''){
        showCustomError('enterNewPass'.tr);
        return;
      }
      if(confirmPass==''){
        showCustomError('enterConfirmPass'.tr);
        return;
      }
      if (!isValidPass(pass)) {
        showCustomError('wrongOldPass'.tr);
        return;
      }
      if (!isValidPass(newPass)) {
        showCustomError('enterValidPass'.tr);
        return;
      }
      if (newPass != confirmPass) {
        showCustomError('diffPass'.tr);
        return;
      }
      this.loading = true;
      showCustomLoading('Loading');
      var private = await wallet.getPrivateKey(pass);
      var net = Network.getNetByRpc(wallet.rpc);
      var isId = wallet.type == 0;
      if (isId) {
        var list = OpenedBox.get<ChainWallet>().values
            .where((wal) => wal.groupHash == wallet.groupHash)
            .toList();
        for (var i = 0; i < list.length; i++) {
          var wal = list[i];
          var same = wal.addressType == wallet.addressType;
          var p = same? private : await wal.getPrivateKey(pass);
          var prefix = wal.rpc == Network.filecoinMainNet.rpc? 'f': 't';
          EncryptKey key = await getKey(wal.addressType, p, newPass, prefix);
          wal.skKek = key.kek;
          box.put(wal.key, wal);
          if (net.rpc == $store.net.rpc) {
            $store.setWallet(wal);
          }
        }
      } else {
        EncryptKey key = await getKey(wallet.addressType, private, newPass, net.prefix);
        wallet.skKek = key.kek;
        box.put(wallet.key, wallet);
        if (net.rpc == $store.net.rpc) {
          $store.setWallet(wallet);
        }
      }
      dismissAllToast();
      this.loading = false;
      Get.back();
      showCustomToast('changePassSucc'.tr);
    } catch (e) {
      this.loading = false;
      dismissAllToast();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'pass'.tr,
      footerText: 'change'.tr,
      onPressed: handleConfrim,
      grey: true,
      body: Padding(
        child: Column(
          children: [
            PassField(
                label: 'oldPass'.tr,
                controller: passCtrl,
                hintText: 'placeholderValidPass'.tr,
            ),
            SizedBox(
              height: 15,
            ),
            PassField(
                label: 'newPass'.tr,
                hintText: 'placeholderValidPass'.tr,
                controller: newCtrl
            ),
            SizedBox(
              height: 15,
            ),
            PassField(
                hintText: 'enterPassAgain'.tr,
                controller: confirmCtrl
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      ),
    );
  }
}
