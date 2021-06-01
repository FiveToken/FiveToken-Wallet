import 'package:fil/index.dart';

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
  var box = Hive.box<Wallet>(addressBox);
  Future<bool> checkValid() async {
    var old = oldCtrl.text.trim();
    var newP = newCtrl.text.trim();
    var newCp = newConfirmCtrl.text.trim();
    if (old == '') {
      showCustomError('enterOldPass'.tr);
      return false;
    }
    var wal = singleStoreController.wal;
    var valid =
        await validatePrivateKey(wal.addrWithNet, old, wal.skKek, wal.digest);
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
    var valid = await checkValid();
    if (!valid) {
      return;
    } else {
      var pass = newCtrl.text.trim();
      var oldPass = oldCtrl.text.trim();
      var wal = singleStoreController.wal;
      var addr = wal.addrWithNet;
      var sk = await getPrivateKey(addr, oldPass, wal.skKek);
      var mne = aesDecrypt(wal.mne, sk);
      var newKek = await genKek(addr, pass);
      var skKek = xor(newKek, base64Decode(sk));
      var digest = await genPrivateKeyDigest(sk);
      if (wal.mne != '') {
        var m = aesEncrypt(mne, sk);
        wal.mne = m;
      }
      wal.skKek = skKek;
      wal.digest = digest;
      OpenedBox.addressInsance.put(addr, wal);
      Global.cacheWallet = wal;
      singleStoreController.setWallet(wal);
      Get.back();
      showCustomToast('changePassSucc'.tr);
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
