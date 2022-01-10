
import 'dart:math';
import 'package:fil/common/utils.dart';
import 'package:fil/utils/enum.dart';
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
  @HiveField(8)
  String baseMaxPriorityFee;
  @HiveField(9)
  String baseFeePerGas;
  @HiveField(10)
  bool isCustomize;

  String get handlingFee{
    try{
      String fee = '0';
      switch(rpcType){
        case RpcType.ethereumMain:
          var feeNum = BigInt.parse(maxFeePerGas) * BigInt.from(gasLimit);
          fee = feeNum.toString();
          break;
        case RpcType.fileCoin:
          var feeNum = (BigInt.parse(gasPremium) + BigInt.parse(gasFeeCap)) * BigInt.from(gasLimit);
          fee = feeNum.toString();
          break;
        case RpcType.ethereumOthers:
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

  ChainGas(
      {this.gasLimit = 0,
        this.gasPremium = '0',
        this.gasPrice = '0',
        this.level = 0,
        this.rpcType = '',
        this.maxPriorityFee = '0',
        this.maxFeePerGas = '0',
        this.gasFeeCap = '0',
        this.baseMaxPriorityFee = '0',
        this.baseFeePerGas = '0',
        this.isCustomize = false
      });
  ChainGas.fromJson(Map<String, dynamic> json) {
    gasPrice = json['gasPrice'] ?? '0';
    gasLimit = json['gasLimit'] ?? 0;
    gasPremium = json['gasPremium'] ?? '0';
    level = json['level'] ?? 0;
    rpcType = json['rpcType'] ?? 0;
    maxPriorityFee = json['maxPriorityFee'] ?? '0';
    maxFeePerGas = json['maxFeePerGas'] ?? '0';
    gasFeeCap = json['gasFeeCap'] ?? '0';
    baseMaxPriorityFee = json['baseMaxPriorityFee'] ?? '0';
    baseFeePerGas = json['baseFeePerGas'] ?? '0';
    isCustomize = json['isCustomize'] ?? false;
  }
}
