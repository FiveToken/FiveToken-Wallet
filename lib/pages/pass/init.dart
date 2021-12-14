import 'package:fil/bloc/pass/pass_bloc.dart';
import 'package:fil/chain/key.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/common/encryptKey.dart';
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
import 'package:fil/common/index.dart';
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

class PassInitPageState extends State<PassInitPage> {
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController passCtrl = TextEditingController();
  TextEditingController passConfirmCtrl = TextEditingController();
  int type; //0 id 1 mne 2 privatekey
  String mne;
  String privateKey;
  Network net;
  String label;
  bool loading = false;
  var box  = OpenedBox.walletInstance;
  bool checkPass() {
    var pass = passCtrl.text.trim();
    var confirm = passConfirmCtrl.text.trim();
    var walletName = nameCtrl.text.trim();
    bool flag = type == WalletType.id;
    if(walletName==''&&flag){
      showCustomError('enterName'.tr);
      return false;
    }
    if (!isValidPass(pass)) {
      showCustomError('placeholderValidPass'.tr);
      return false;
    } else if(!isValidPass(confirm)){
      showCustomError('placeholderValidPass'.tr);
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
    type = arg['type'];
    if(arg['type']==WalletType.id){
      nameCtrl.text = arg['label'];
    }
    mne = arg['mne'];
    label = arg['label'];
    privateKey = arg['privateKey'];
    net = arg['net'];
  }


  ChainWallet getWallet(type, EncryptKey key,Network net){
    return ChainWallet(
      label: label,
      mne: type!= WalletType.privateKey ?aesEncrypt(mne, key.private): '',
      groupHash: type!= WalletType.privateKey ?tokenify(mne): '',
      type: type,
      rpc: net.rpc,
      addressType: net.addressType,
      digest: key.digest,
      address: key.address,
      skKek: key.kek,
    );
  }

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

  void AddWallet(ChainWallet wallet) async{
    var box = OpenedBox.walletInstance;
    await box.put(wallet.key, wallet);
  }

  void handleSubmit() async {
    String pass = passCtrl.text.trim();
    String walletName = nameCtrl.text.trim();
    if (!checkPass()) {
      return;
    }
    if (loading) {
      return;
    }
    this.loading = true;
    showCustomLoading('Loading');
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
            var wal;
            try {
              EncryptKey key = keyMap[addrType];
              wal = getWallet(type, key, net);
              AddWallet(wal);
            }catch(e){
              print(e);
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
        print(e);
        this.loading = false;
        dismissAllToast();
      }
    } else if (type == WalletType.mne) {
      try {
        EncryptKey key = await getKey(net.addressType, pass, mne, net.prefix);
        var wal = getWallet(type, key, net);
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
        print(e);
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
        var wal = getWallet(type, key, net);
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
        print(e);
        this.loading = false;
        showCustomError('importFail'.tr);
      }
    }

    this.loading = false;
    dismissAllToast();

    // Navigator.popUntil(context, (route){
    //   print( route.settings.name);
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
  void onTap(context, state){
    BlocProvider.of<PassBloc>(context)..add(SetPassEvent(passShow: !state.passShow));
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
                      onTap: ()=>{onTap(ctx, state)},
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
