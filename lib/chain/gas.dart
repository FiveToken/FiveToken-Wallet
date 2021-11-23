
import 'dart:math';
import 'package:fil/common/utils.dart';
import 'package:hive/hive.dart';
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
  @HiveField(4)
  String rpcType;
  @HiveField(5)
  String maxPriorityFee;
  @HiveField(6)
  String maxFeePerGas;
  @HiveField(7)
  String gasFeeCap;

  String get handlingFee{
    try{
      String fee = '0';
      switch(rpcType){
        case 'ethMain':
          var feeNum = BigInt.parse(maxFeePerGas) * BigInt.from(gasLimit);
          fee = feeNum.toString();
          break;
        case 'filecoin':
          var feeNum = (BigInt.parse(gasPremium) + BigInt.parse(gasFeeCap)) * BigInt.from(gasLimit);
          fee = feeNum.toString();
          break;
        case 'ethOthers':
          var feeNum = BigInt.parse(gasPrice) * BigInt.from(gasLimit);
          fee = feeNum.toString();
          break;
        default:
          fee = '0';
      }
      return fee;
    }catch(error){
      return '0';
    }
  }

  String get handlingFeeMinUnit{
    var unit = BigInt.from(pow(10, 18));
    var num = double.parse(this.handlingFee);
    return this.handlingFee;
  }

  ChainGas(
      {this.gasLimit = 0,
        this.gasPremium = '0',
        this.gasPrice = '0',
        this.level = 0,
        this.rpcType = '',
        this.maxPriorityFee = '',
        this.maxFeePerGas = '',
        this.gasFeeCap = ''
      });
  ChainGas.fromJson(Map<String, dynamic> json) {
    gasPrice = json['gasPrice'] ?? '0';
    gasLimit = json['gasLimit'] ?? 0;
    gasPremium = json['gasPremium'] ?? '0';
    level = json['level'] ?? 0;
    rpcType = json['rpcType'] ?? 0;
    maxPriorityFee = json['maxPriorityFee'] ?? '0';
    maxFeePerGas = json['maxFeePerGas'];
    gasFeeCap = json['gasFeeCap'];
  }
}
