import 'package:fil/bloc/pass/pass_bloc.dart';
import 'package:fil/chain/key.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fil/index.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/index.dart';
import 'package:fil/models/index.dart';
import 'package:fil/store/store.dart';
import 'package:fil/init/hive.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class PassInitPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PassInitPageState();
  }
}

class PassInitPageState extends State<PassInitPage> {
  TextEditingController passCtrl = TextEditingController();
  TextEditingController passConfirmCtrl = TextEditingController();
  int type; //0 id 1 mne 2 privatekey
  String mne;
  String privateKey;
  Network net;
  String label;
  bool loading = false;
  var box = OpenedBox.walletInstance;
  bool checkPass() {
    var pass = passCtrl.text.trim();
    var confirm = passConfirmCtrl.text.trim();
    if (!isValidPassword(pass)) {
      showCustomError('enterValidPass'.tr);
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
    var arg = Get.arguments ?? {'type': 0};
    type = arg['type'];
    mne = arg['mne'];
    label = arg['label'];
    privateKey = arg['privateKey'];
    net = arg['net'];
  }

  void handleSubmit() async {
    String pass = passCtrl.text.trim();
    if (!checkPass()) {
      return;
    }
    if (loading) {
      return;
    }

    this.loading = true;
    showCustomLoading('Loading');
    if (type == 0 || (type == 1 && net == null)) {
      try {
        Map<String, EncryptKey> keyMap = {};
        var ethPk = await compute(EthWallet.genPrivateKeyByMne, mne);
        var filPk = await compute(FilecoinWallet.genPrivateKeyByMne, mne);
        keyMap['eth'] = await EthWallet.genEncryptKeyByPrivateKey(ethPk, pass);
        keyMap['filecoin'] =
            await FilecoinWallet.genEncryptKeyByPrivateKey(filPk, pass);
        keyMap['calibration'] = await FilecoinWallet.genEncryptKeyByPrivateKey(
            filPk, pass,
            prefix: 't');
        var key = keyMap['eth'].address + '_' + Network.ethMainNet.rpc + '_0';
        if (box.containsKey(key)) {
          showCustomError('errorExist'.tr);
          this.loading = false;
          return;
        }
        for (var nets in Network.netList) {
          for (var net in nets) {
            var type = net.addressType;
            EncryptKey key = keyMap[type];
            if (net.rpc == Network.filecoinTestNet.rpc) {
              key = keyMap[net.net];
            }
            var wal = ChainWallet(
                label: label,
                mne: aesEncrypt(mne, key.private),
                groupHash: tokenify(mne),
                type: 0,
                rpc: net.rpc,
                addressType: type);
            wal.digest = key.digest;
            wal.address = key.address;
            wal.skKek = key.kek;
            box.put(wal.key, wal);
            var currentNet = $store.net;
            if (currentNet.rpc == net.rpc) {
              $store.setWallet(wal);
              Global.store.setString('currentWalletAddress', wal.key);
            }
          }
        }
      } catch (e) {
        print(e);
        this.loading = false;
        dismissAllToast();
      }
    } else if (type == 1 && net != null) {
      try {
        EncryptKey key;
        if (net.addressType == 'eth') {
          var private = await compute(EthWallet.genPrivateKeyByMne, mne);
          key = await EthWallet.genEncryptKeyByPrivateKey(private, pass);
        } else {
          var private = await compute(FilecoinWallet.genPrivateKeyByMne, mne);
          key = await FilecoinWallet.genEncryptKeyByPrivateKey(private, pass,
              prefix: net.prefix);
        }
        var wal = ChainWallet(
            label: label,
            mne: aesEncrypt(mne, key.private),
            groupHash: tokenify(mne),
            type: 1,
            rpc: net.rpc,
            addressType: net.addressType);
        wal.digest = key.digest;
        wal.address = key.address;
        wal.skKek = key.kek;
        if (box.containsKey(wal.key)) {
          showCustomError('errorExist'.tr);
          this.loading = false;
          return;
        }
        box.put(wal.key, wal);
        $store.setWallet(wal);
        $store.setNet(net);
        Global.store.setString('currentWalletAddress', wal.key);
        Global.store.setString('activeNetwork', net.rpc);
      } catch (e) {
        print(e);
        dismissAllToast();
        this.loading = false;
      }
    } else {
      try {
        EncryptKey key;
        if (net.addressType == 'eth') {
          if (privateKey.length > 64) {
            showCustomError('wrongPk'.tr);
            this.loading = false;
            return;
          }
          key = await EthWallet.genEncryptKeyByPrivateKey(privateKey, pass);
        } else {
          PrivateKey filPk =
              PrivateKey.fromMap(jsonDecode(hex2str(privateKey)));
          var type = filPk.type == 'secp256k1' ? SignSecp : SignBls;
          var pk = filPk.privateKey;
          key = await FilecoinWallet.genEncryptKeyByPrivateKey(pk, pass,
              type: type, prefix: net.prefix);
        }

        var wal = ChainWallet(
            label: label,
            mne: '',
            groupHash: '',
            type: 2,
            rpc: net.rpc,
            addressType: net.addressType);
        wal.digest = key.digest;
        wal.address = key.address;
        wal.skKek = key.kek;
        if (box.containsKey(wal.key)) {
          showCustomError('errorExist'.tr);
          this.loading = false;
          return;
        }
        box.put(wal.key, wal);
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
    Get.offAllNamed(mainPage);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      grey: true,
      title: 'pass'.tr,
      footerText: 'next'.tr,
      onPressed: () {
        handleSubmit();
      },
      body: Padding(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            PassField(
              controller: passCtrl,
              label: 'setPass'.tr,
              hintText: 'enterValidPass'.tr,
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
