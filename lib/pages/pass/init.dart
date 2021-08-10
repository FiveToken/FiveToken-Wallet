import 'package:fil/chain/key.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';

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
    if (type == 0 || (type == 1 && net == null)) {
      Map<String, EncryptKey> keyMap = {};
      keyMap['eth'] = await EthWallet.genEncryptKey(mne, pass);
      keyMap['filecoin'] = await FilecoinWallet.genEncryptKey(mne, pass);
      try {
        for (var nets in Network.netList) {
          for (var net in nets) {
            var type = net.addressType;
            EncryptKey key = keyMap[type];
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
            OpenedBox.walletInstance.put(wal.key, wal);
            var currentNet = $store.net;
            if (currentNet.addressType == type) {
              $store.setWallet(wal);
              Global.store.setString('currentWalletAddress', wal.address);
            }
          }
        }
      } catch (e) {
        print(e);
      }
    } else if (type == 1 && net != null) {
      EncryptKey key;
      if (net.addressType == 'eth') {
        key = await EthWallet.genEncryptKey(mne, pass);
      } else {
        key = await FilecoinWallet.genEncryptKey(mne, pass);
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
      OpenedBox.walletInstance.put(wal.key, wal);
      $store.setWallet(wal);
      $store.setNet(net);
      Global.store.setString('currentWalletAddress', wal.address);
    } else {
      try {
        EncryptKey key;
        if (net.addressType == 'eth') {
          if (privateKey.length > 32) {
            showCustomError('私钥格式错误');
            return;
          }
          key = await EthWallet.genEncryptKeyByPrivateKey(privateKey, pass);
        } else {
          PrivateKey filPk =
              PrivateKey.fromMap(jsonDecode(hex2str(privateKey)));
          var type = filPk.type == 'secp256k1' ? SignSecp : SignBls;
          var pk = filPk.privateKey;
          key = await FilecoinWallet.genEncryptKeyByPrivateKey(pk, pass,
              type: type);
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
          OpenedBox.walletInstance.put(wal.key, wal);
          $store.setWallet(wal);
          $store.setNet(net);
          Global.store.setString('currentWalletAddress', wal.address);
        }
      } catch (e) {
        showCustomError('导入失败');
      }
    }
    this.loading = false;
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
  bool passShow = false;

  @override
  Widget build(BuildContext context) {
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
                obscureText: !passShow,
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
                    image: AssetImage(!passShow
                        ? 'icons/close-eye-d.png'
                        : 'icons/open-d.png')),
                onTap: () {
                  setState(() {
                    passShow = !passShow;
                  });
                },
              ),
              // IconButton(
              //   icon: Image(
              //       width: 22,
              //       image: AssetImage(!passShow
              //           ? 'icons/close-eye-d.png'
              //           : 'icons/open-d.png')),
              //   onPressed: () {
              //     setState(() {
              //       passShow = !passShow;
              //     });
              //   },
              // )
            ],
          ),
        )
      ],
    );
  }
}
