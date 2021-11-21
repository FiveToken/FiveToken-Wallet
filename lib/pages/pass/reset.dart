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
  final TextEditingController oldCtrl = TextEditingController();
  final TextEditingController newCtrl = TextEditingController();
  final TextEditingController newConfirmCtrl = TextEditingController();
  var box = OpenedBox.get<ChainWallet>();
  bool loading = false;
  ChainWallet wallet = Get.arguments['wallet'];
  Future<bool> checkValid() async {
    var old = oldCtrl.text.trim();
    var newP = newCtrl.text.trim();
    var newCp = newConfirmCtrl.text.trim();
    if (old == '') {
      showCustomError('enterOldPass'.tr);
      return false;
    }
    var valid = await wallet.validatePrivateKey(old);
    if (!valid) {
      showCustomError('wrongOldPass'.tr);
      return false;
    }
    if (!isValidPassword(newP)) {
      showCustomError('enterValidPass'.tr);
      return false;
    }
    if (newP != newCp) {
      showCustomError('diffPass'.tr);
      return false;
    }
    return true;
  }

  void handleConfrim() async {
    if (loading) {
      return;
    }
    this.loading = true;
    showCustomLoading('Loading');
    try {
      var valid = await checkValid();
      var old = oldCtrl.text.trim();
      var newP = newCtrl.text.trim();
      var private = await wallet.getPrivateKey(old);
      if (!valid) {
        this.loading = false;
        return;
      } else {
        var net = Network.getNetByRpc(wallet.rpc);
        var isId = wallet.type == 0;
        if (isId) {
          var list = OpenedBox.get<ChainWallet>().values
              .where((wal) => wal.groupHash == wallet.groupHash)
              .toList();
          for (var i = 0; i < list.length; i++) {
            var wal = list[i];
            var p = private;
            var same = wal.addressType == wallet.addressType;
            if (!same) {
              p = await wal.getPrivateKey(old);
            }
            EncryptKey key;
            if (wal.addressType == 'eth') {
              key = await EthWallet.genEncryptKeyByPrivateKey(p, newP);
            } else {
               var prefix = wal.rpc == Network.filecoinMainNet.rpc? 'f': 't';
               key = await FilecoinWallet.genEncryptKeyByPrivateKey(p, newP,
                   prefix: prefix);
            }
            wal.skKek = key.kek;
            box.put(wal.key, wal);
            if (net.rpc == $store.net.rpc) {
              $store.setWallet(wal);
            }
          }
        } else {
          EncryptKey key;
          if (wallet.addressType == 'eth') {
            key = await EthWallet.genEncryptKeyByPrivateKey(private, newP);
          } else {
            key = await FilecoinWallet.genEncryptKeyByPrivateKey(private, newP,
                prefix: net.prefix);
          }
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
      }
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
            PassField(label: 'oldPass'.tr, controller: oldCtrl),
            SizedBox(
              height: 15,
            ),
            PassField(
                label: 'newPass'.tr,
                hintText: 'enterValidPass'.tr,
                controller: newCtrl),
            SizedBox(
              height: 15,
            ),
            PassField(
                hintText: 'enterPassAgain'.tr, controller: newConfirmCtrl),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      ),
    );
  }
}
