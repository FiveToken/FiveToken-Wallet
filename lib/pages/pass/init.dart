import 'dart:typed_data';
import 'package:fil/bloc/pass/pass_bloc.dart';
import 'package:fil/chain/key.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/common/argon2.dart';
import 'package:fil/common/encryptKey.dart';
import 'package:fil/pages/wallet/widgets/strengthPassword.dart';
import 'package:fil/utils/decimal_extension.dart';
import 'package:fil/common/utils.dart' show zxcvbnLevel;
import 'package:fil/widgets/field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/common/global.dart';
import 'package:fil/store/store.dart';
import 'package:fil/init/hive.dart';
import 'package:flutter/services.dart';
import 'package:fil/utils/enum.dart';

class PassInitPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PassInitPageState();
  }
}

// Page of Password initialization
class PassInitPageState extends State<PassInitPage> {
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController passCtrl = TextEditingController();
  TextEditingController passConfirmCtrl = TextEditingController();
  int type;
  String mne;
  String privateKey;
  Network net;
  String label;
  bool loading = false;
  var box  = OpenedBox.walletInstance;
  num level = 0;

  bool checkForm() {
    FocusNode().requestFocus();
    var pass = passCtrl.text.trim();
    var confirm = passConfirmCtrl.text.trim();
    var walletName = nameCtrl.text.trim();
    bool flag = type == WalletType.id;
    if(walletName==''&&flag){
      showCustomError('enterName'.tr);
      return false;
    }
    if(level < 4 ){
      showCustomError('levelTips'.tr);
      return false;
    } else if (pass != confirm) {
      showCustomError('diffPass'.tr);
      return false;
    } else {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    var arg = Get.arguments ?? {'type': WalletType.id};
    type = arg['type'] as int;
    if(arg['type']==WalletType.id){
      nameCtrl.text = arg['label'] as String;
    }
    mne = arg['mne'] as String;
    label = arg['label'] as String;
    privateKey = arg['privateKey'] as String;
    net = arg['net'] as Network;

    passCtrl.addListener(() {
      if(passCtrl.text != ''){
        level = zxcvbnLevel(passCtrl.text);
      }
      setState(() {});
    });
  }

  // get wallet
  ChainWallet getWallet(int type, EncryptKey key,Network net, String mne, String goupHash){
    return ChainWallet(
      label: label,
      mne: type!= WalletType.privateKey ?mne: '',
      groupHash: type!= WalletType.privateKey ? goupHash: '',
      type: type,
      rpc: net.rpc,
      addressType: net.addressType,
      digest: key.digest,
      address: key.address,
      skKek: key.kek,
    );
  }
  // update wallet name
  void updateName(String newLabel) async{
    var box = OpenedBox.walletInstance;
    var wallet = $store.wal;
    var list = box.values.where((wal)=> wal.groupHash == wallet.groupHash);
    list.forEach((wal)=>{
      wal.label = newLabel,
      box.put(wal.key, wal)
    });
    $store.changeWalletName(newLabel);
  }
  // add wallet
  void AddWallet(ChainWallet wallet) async{
    var box = OpenedBox.walletInstance;
    await box.put(wallet.key, wallet);
  }
 // submit form information and initialize Wallet
  void handleSubmit() async {
    String pass = passCtrl.text.trim();
    String walletName = nameCtrl.text.trim();
    if (!checkForm()) {
      return;
    }
    if (loading) {
      return;
    }
    this.loading = true;
    showCustomLoading('Loading');
    String groupHash = randomNonce().toEncode();
    // initialize Wallet
    if (type == WalletType.id) {
      try {
        Map<String, EncryptKey> keyMap = await getKeyMap(mne, pass);
        EncryptKey ethKey = keyMap['eth'];
        var key = ethKey.address + '_' + Network.ethMainNet.rpc + '_0';
        if (box.containsKey(key)) {
          showCustomError('errorExist'.tr);
          this.loading = false;
          return;
        }
        for (var nets in Network.netList) {
          for (var net in nets) {
            var addrType = net.rpc == Network.filecoinTestNet.rpc? net.net: net.addressType;
            ChainWallet wal;
            try {
              EncryptKey key = keyMap[addrType];
              Uint8List mneStr = await encryptSodium(mne, 'mne', pass);
              wal = getWallet(type, key, net, mneStr.toEncode(), groupHash);
              AddWallet(wal);
            }catch(e){
              return null;
            }
            var currentNet = $store.net;
            if (currentNet.rpc == net.rpc) {
              $store.setWallet(wal);
              Global.store.setString('currentWalletAddress', wal.key);
            }
          }
        }
        updateName(walletName);
      } catch (e) {
        this.loading = false;
        dismissAllToast();
      }
    } else if (type == WalletType.mne) {
      try {
        EncryptKey key = await getKey(net.addressType, pass, mne, net.prefix);
        Uint8List mneStr = await encryptSodium(mne, 'mne', pass);
        var wal = getWallet(type, key, net, mneStr.toEncode(), groupHash);
        if (box.containsKey(wal.key)) {
          showCustomError('errorExist'.tr);
          this.loading = false;
          return;
        }
        await AddWallet(wal);
        $store.setWallet(wal);
        $store.setNet(net);
        Global.store.setString('currentWalletAddress', wal.key);
        Global.store.setString('activeNetwork', net.rpc);
      } catch (e) {
        this.loading = false;
        dismissAllToast();
      }
    } else {
      try {
        EncryptKey key = await getKey2(net.addressType, privateKey, pass, net);
        if (net.addressType == 'eth' && privateKey.length > 64) {
          showCustomError('wrongPk'.tr);
          this.loading = false;
          return;
        }
        var wal = getWallet(type, key, net, '', groupHash);
        if (box.get(wal.key)!=null) {
          showCustomError('errorExist'.tr);
          this.loading = false;
          return;
        }
        await AddWallet(wal);
        $store.setWallet(wal);
        $store.setNet(net);
        Global.store.setString('currentWalletAddress', wal.key);
        Global.store.setString('activeNetwork', net.rpc);
      } catch (e) {
        this.loading = false;
        showCustomError('importFail'.tr);
      }
    }

    this.loading = false;
    dismissAllToast();
    // Navigator.popUntil(context, (route){
    //   return route.settings.name == mainPage;
    // });
    Global.lockFromInit = false;
    Get.offAllNamed(mainPage);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      grey: true,
      title: 'pass'.tr,
      footerText: 'sure'.tr,
      onPressed: () {
        handleSubmit();
      },
      body: Padding(
        child: Column(
          children: [
            Visibility(child: Field(
              label:  'walletName'.tr,
              controller: nameCtrl,
              placeholder: 'placeholderWalletName'.tr,
              maxLength: 20,
            ),
              visible: type == WalletType.id,
            ),
            SizedBox(
              height: 15,
            ),
            PassField(
              controller: passCtrl,
              label: 'setPass'.tr,
              hintText: 'placeholderValidPass'.tr,
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
              height: 20,
            ),
            PassField(
              controller: passConfirmCtrl,
              label: '',
              hintText: 'enterPassAgain'.tr,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

class PassField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool autofocus;
  PassField(
      {this.controller,
      this.label = '',
      this.hintText = '',
      this.autofocus = false});
  @override
  State<StatefulWidget> createState() {
    return PassFieldState();
  }
}

class PassFieldState extends State<PassField> {
  void onTap(BuildContext context, bool show){
    BlocProvider.of<PassBloc>(context)..add(SetPassEvent(passShow: show));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => PassBloc()..add(SetPassEvent()),
        child: BlocBuilder<PassBloc, PassState>(builder: (ctx, state){
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                child: Column(
                  children: [
                    CommonText(
                      widget.label,
                      size: 14,
                      weight: FontWeight.w500,
                    ),
                    SizedBox(
                      height: 13,
                    ),
                  ],
                ),
                visible: widget.label != '',
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          autofocus: widget.autofocus,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp("[^\u4e00-\u9fa5]"),
                            ),
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            LengthLimitingTextInputFormatter(20)
                          ],
                          style: TextStyle(fontSize: 12),
                          obscureText: !state.passShow,
                          controller: widget.controller,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration.collapsed(
                              hintText: widget.hintText,
                              hintStyle:
                              TextStyle(color: Color(0xffcccccc), fontSize: 14)),
                        )),
                    GestureDetector(
                      child: Image(
                          width: 22,
                          image: AssetImage(!state.passShow
                              ? 'icons/close-eye-d.png'
                              : 'icons/open-d.png')),
                      onTap: ()=>{onTap(ctx, !state.passShow)},
                    ),
                  ],
                ),
              )
            ],
          );
        }),
    );
  }
}
