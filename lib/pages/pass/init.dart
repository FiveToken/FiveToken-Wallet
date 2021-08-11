import 'package:fil/index.dart';
/// set password of a wallet
class PassInitPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PassInitPageState();
  }
}

class PassInitPageState extends State<PassInitPage> {
  TextEditingController passCtrl = TextEditingController();
  TextEditingController passConfirmCtrl = TextEditingController();
  bool mneCreate;
  Wallet wallet = Get.arguments['wallet'] as Wallet;
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
    mneCreate = Get.arguments != null && Get.arguments['create'] == true;
  }

  void handleSubmit() async {
    if (!checkPass()) {
      return;
    }
    unFocusOf(context);
    String pass = passCtrl.text.trim();
    var addr = wallet.addrWithNet;
    var ck = wallet.ck;
    var kek = await genKek(addr, pass);
    var pkList = base64Decode(ck);
    var skKek = xor(kek, pkList);
    if (wallet.mne != '') {
      var m = aesEncrypt(wallet.mne, ck);
      wallet.mne = m;
    }
    var digest = await genPrivateKeyDigest(ck);
    wallet.skKek = skKek;
    wallet.digest = digest;
    wallet.ck = '';
    Global.store.setString('currentWalletAddress', addr);
    OpenedBox.addressInsance.put(addr, wallet);
    singleStoreController.setWallet(wallet);
    Get.offAllNamed(mainPage, arguments: {'create': mneCreate});
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
