import 'package:fil/index.dart';
import 'package:get/get.dart';

class StoreController extends GetxController {
  var wallet = Wallet().obs;
  var gas = Gas().obs;
  var message = StoreMessage().obs;
  var scanResult = ''.obs;
  Wallet get wal {
    return wallet.value;
  }

  StoreMessage get mes {
    return message.value;
  }

  String get maxFee {
    return getMaxFee(gas.value);
  }

  void setWallet(Wallet wal) async {
    wallet.value = Wallet.fromJson(wal.toJson());
  }

  void changeWalletName(String label) {
    wallet.update((val) {
      val.label = label;
    });
  }

  void changeWalletAddress(String addr) {
    wallet.update((val) {
      val.address = addr;
    });
  }

  void changeWalletBalance(String balance) {
    wallet.update((val) {
      val.balance = balance;
    });
  }

  void setGas(Gas g) {
    gas.value = g;
  }

  void setMessage(StoreMessage mes) {
    message.value = mes;
  }

  void scan(String res) {
    scanResult.value = res;
  }
}

StoreController singleStoreController = Get.find();
