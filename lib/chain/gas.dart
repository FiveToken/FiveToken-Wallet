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
      return formatCoin(
          (BigInt.from(gasLimit) * BigInt.parse(gasPrice)).toString());
    } catch (e) {
      return '';
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
