import 'package:fil/index.dart';

class AddressBookAddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddressBookAddPageState();
  }
}

class AddressBookAddPageState extends State<AddressBookAddPage> {
  TextEditingController addrCtrl = TextEditingController();
  TextEditingController nameCtrl = TextEditingController();
  Wallet wallet;
  var box = Hive.box<Wallet>(addressBookBox);
  int mode = 0;
  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments['mode'] != null) {
      wallet = Get.arguments['wallet'] as Wallet;
      mode = 1;
      addrCtrl.text = wallet.addr;
      nameCtrl.text = wallet.label;
    }
  }

  bool checkValid() {
    var addr = addrCtrl.text.trim();
    var name = nameCtrl.text.trim();
    if (!isValidAddress(addr)) {
      showCustomError('enterValidAddr'.tr);
      return false;
    }
    if (name == '' || name.length > 20) {
      showCustomError('enterTag'.tr);
      return false;
    }
    if (box.containsKey(addr) && !edit) {
      showCustomError('errorExist'.tr);
      return false;
    }
    return true;
  }

  void handleConfirm() {
    if (!checkValid()) {
      return;
    }
    var address = addrCtrl.text.trim();
    var label = nameCtrl.text.trim();
    var type = address[1];
    if (edit) {
      box.delete(wallet.address);
    }
    box.put(address,
        Wallet(type: type, label: label, address: address, walletType: 1));
    showCustomToast(!edit ? 'addAddrSucc'.tr : 'changeAddrSucc'.tr);
    Get.back();
  }

  bool get edit {
    return wallet != null;
  }

  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
        .then((scanResult) {
      if (scanResult != '') {
        if (isValidAddress(scanResult)) {
          addrCtrl.text = scanResult;
        } else {
          showCustomError('wrongAddr'.tr);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: !edit ? 'addAddr'.tr : 'manageAddr'.tr,
      footerText: !edit ? 'add'.tr : 'save'.tr,
      grey: true,
      onPressed: handleConfirm,
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
            Field(
              controller: addrCtrl,
              label: 'contactAddr'.tr,
              append: GestureDetector(
                child: Image(width: 20, image: AssetImage('icons/cop.png')),
                onTap: () async {
                  var data = await Clipboard.getData(Clipboard.kTextPlain);
                  addrCtrl.text = data.text;
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Field(
              controller: nameCtrl,
              label: 'remark'.tr,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      ),
    );
  }
}
