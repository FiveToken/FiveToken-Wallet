import 'package:fil/index.dart';
part 'gas.g.dart';

@HiveType(typeId: 12)
class ChainGas {
  @HiveField(0)
  String gasPrice;
  @HiveField(1)
  String gasPremium;
  @HiveField(2)
  int gasLimit;
  @HiveField(3)
  int level;
  String get maxFee {
    try {
      return formatCoin(feeNum.toString(), size: 5);
    } catch (e) {
      return '';
    }
  }

  BigInt get feeNum {
    try {
      return BigInt.from(gasLimit) * BigInt.parse(gasPrice);
    } catch (e) {
      return BigInt.zero;
    }
  }

  ChainGas get fast {
    var res = ChainGas();
    try {
      var net = $store.net;
      var price = double.parse(gasPrice);
      if (net.addressType == 'eth' && price > 10 * pow(10, 9)) {
        price += 2 * pow(10, 9);
      } else {
        price = 1.1 * price;
      }
      res
        ..gasLimit = gasLimit
        ..gasPremium = gasPremium
        ..gasPrice = price.truncate().toString()
        ..level = 0;
      return res;
    } catch (e) {
      return res;
    }
  }

  ChainGas get slow {
    var res = ChainGas();
    try {
      var net = $store.net;
      var price = double.parse(gasPrice);
      var premium = double.parse(gasPremium);
      if (net.addressType == 'eth' && price > 10 * pow(10, 9)) {
        price -= 2 * pow(10, 9);
      } else {
        price = 0.9 * price;
        premium = price - 100;
      }
      res
        ..gasLimit = gasLimit
        ..gasPremium = premium.truncate().toString()
        ..gasPrice = price.truncate().toString()
        ..level = 1;
      return res;
    } catch (e) {
      return res;
    }
  }

  ChainGas(
      {this.gasLimit = 0,
      this.gasPremium = '0',
      this.gasPrice = '0',
      this.level = 0});
  ChainGas.fromJson(Map<String, dynamic> json) {
    gasPrice = json['feeCap'];
    gasLimit = json['gasLimit'];
    gasPremium = json['premium'];
    level = json['level'];
  }
}
