import 'package:fil/chain/key.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/pages/wallet/widgets/strengthPassword.dart';
import 'package:fil/widgets/text.dart';
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
// Page of reset password
class PassResetPageState extends State<PassResetPage> {
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController newCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();
  var box = OpenedBox.walletInstance;
  bool loading = false;
  num level = 0;
  ChainWallet wallet = Get.arguments!=null?Get.arguments['wallet'] as ChainWallet:ChainWallet();

  Future<EncryptKey> getKey(String addressType, String privateKey,  String pass, String prefix) async{
    EncryptKey key;
    if(addressType=='eth') {
      try {
        key = await EthWallet.genEncryptKeyByPrivateKey(privateKey, pass);
      }
      catch (e) { }
    }else{
      try{ key = await FilecoinWallet.genEncryptKeyByPrivateKey(privateKey, pass,  prefix: prefix); }
      catch(e){}
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
      if(level < 4 ){
        showCustomError('levelTips'.tr);
        return ;
      }

      if (newPass != confirmPass) {
        showCustomError('diffPass'.tr);
        return;
      }
      this.loading = true;
      showCustomLoading('Loading');
      var private = await wallet.getPrivateKey(pass);
      if(private==null){
        showCustomError('wrongOldPass'.tr);
        return;
      }
      var net = Network.getNetByRpc(wallet.rpc);
      var isId = wallet.type == 0;
      if (isId) {
        var list = OpenedBox.walletInstance.values
            .where((wal) => wal.groupHash == wallet.groupHash)
            .toList();
        Map<String, EncryptKey> keyMap = {};
        for (var i = 0; i < list.length; i++) {
          var wal = list[i];
          var same = wal.addressType == wallet.addressType;
          var p = private;
          if(!same){
            try {
              p = await wal.getPrivateKey(pass);
            }catch(e){}
          }
          var prefix = wal.rpc == Network.filecoinMainNet.rpc? 'f': 't';
          // var addr = wal.addressType;
          EncryptKey key;
          if(wal.addressType == 'eth'){
            var str = '$p\_$newPass';
            if(!keyMap.containsKey(str)){
              key = await EthWallet.genEncryptKeyByPrivateKey(p, newPass);
              keyMap[str] = key;
            }else{
              key = keyMap[str];
            }
          }else{
            var str = '$p\_$newPass\_$prefix';
            if(!keyMap.containsKey(str)){
              key = await FilecoinWallet.genEncryptKeyByPrivateKey(p, newPass,
                  prefix: prefix);
              keyMap[str] = key;
            }else{
              key = keyMap[str];
            }
          }
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
  void initState() {
    newCtrl.addListener(() {
      if(newCtrl.text != ''){
        level = zxcvbnLevel(newCtrl.text);
      }
      setState(() {});
    });
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
            CustomPaint(
              painter: StrengthPassword(level: level, context: context),
              child: Center(),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: CommonText(
                      'strengthTips'.tr,
                      size: 14,
                      color: Colors.black,
                      weight: FontWeight.w500,)
                )
              ],
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
