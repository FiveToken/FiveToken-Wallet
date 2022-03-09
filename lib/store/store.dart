import 'package:fil/chain/gas.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/chain/wallet.dart';
import 'package:get/get.dart';

class StoreController extends GetxController {
  var wallet = ChainWallet().obs;
  var g = ChainGas().obs;
  var scanResult = ''.obs;
  var network = Network().obs;
  var tok = Token().obs;
  var encryptionType = ''.obs;
  ChainWallet get wal {
    return wallet.value;
  }

  Network get net {
    return network.value;
  }

  ChainGas get gas {
    return g.value;
  }

  Token get token {
    return tok.value;
  }

  void setWallet(ChainWallet wal) async {
    wallet.value = ChainWallet.fromJson(wal.toJson());
  }

  void setNet(Network net) {
    network.value = net;
  }

  void setToken(Token t) {
    tok.value = t;
  }

  void changeWalletName(String label) {
    wallet.update((val) {
      val.label = label;
    });
  }

  void changeWalletBalance(String balance) {
    wallet.update((val) {
      val.balance = balance;
    });
  }

  void setGas(ChainGas gas) {
    g.value = gas;
  }

  void setEncryptionType(String type){
    encryptionType.value = type;
  }
}

StoreController $store = Get.find();
