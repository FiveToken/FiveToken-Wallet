// import 'package:fil/common/utils.dart';
// import 'package:hive/hive.dart';
//
// @HiveType(typeId: 12)
// class ChainGas {
//   @HiveField(0)
//   String gasPrice;
//   @HiveField(1)
//   String gasPremium;
//   @HiveField(2)
//   int gasLimit;
//   @HiveField(3)
//   int level;
//   @HiveField(4)
//   String rpcType;
//   @HiveField(5)
//   String maxPriorityFee;
//   @HiveField(6)
//   String maxFeeEth;
//   @HiveField(7)
//   String gasFeeCap;
//
//   String get handlingFee{
//     String fee = '0';
//     switch(rpcType){
//       case 'ethMain':
//         var feeNum = BigInt.parse(maxFeeEth) * BigInt.parse(gasPrice);
//         fee = formatCoin(feeNum.toString(), size: 5);
//         return fee;
//         break;
//       case 'filecoin':
//         var feeNum = (BigInt.parse(gasPremium) + BigInt.parse(gasFeeCap)) * BigInt.from(gasLimit);
//         fee = formatCoin(feeNum.toString(), size: 5);
//         return fee;
//         break;
//       case 'ethOthers':
//         var feeNum = BigInt.from(gasLimit) * BigInt.parse(gasPrice);
//         fee = formatCoin(feeNum.toString(), size: 5);
//         return fee;
//         break;
//       default:
//         return fee;
//     }
//   }
//
//   String get maxFee {
//     try {
//       return formatCoin(feeNum.toString(), size: 5);
//     } catch (e) {
//       return '';
//     }
//   }
//
//   BigInt get feeNum {
//     try {
//       return BigInt.from(gasLimit) * BigInt.parse(gasPrice);
//     } catch (e) {
//       return BigInt.zero;
//     }
//   }
//
//   ChainGas(
//       {
//         this.gasLimit = 0,
//         this.gasPremium = '0',
//         this.gasPrice = '0',
//         this.level = 0,
//         this.rpcType = '',
//         this.maxPriorityFee = '',
//         this.maxFeeEth = '',
//         this.gasFeeCap = ''
//       }
//     );
//   ChainGas.fromJson(Map<String, dynamic> json) {
//     gasPrice = json['feeCap'] ?? '0';
//     gasLimit = json['gasLimit'] ?? 0;
//     gasPremium = json['premium'] ?? '0';
//     level = json['level'] ?? 0;
//     rpcType = json['rpcType'] ?? 0;
//     maxPriorityFee = json['maxPriorityFee'] ?? '0';
//     maxFeeEth = json['maxFeeEth'];
//     gasFeeCap = json['gasFeeCap'];
//   }
// }
