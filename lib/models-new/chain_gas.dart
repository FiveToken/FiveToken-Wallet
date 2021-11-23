// import 'package:fil/common/utils.dart';
// import 'package:hive/hive.dart';
// import 'dart:math';
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
//   String maxFeePerGas;
//   @HiveField(7)
//   String gasFeeCap;
//
//   String get handlingFee{
//     try{
//       String fee = '0';
//       switch(rpcType){
//         case 'ethMain':
//           var unit = BigInt.from(pow(10, 18));
//           var feeNum = BigInt.parse(maxFeePerGas) * BigInt.from(gasLimit)/unit;
//           fee = formatCoin(feeNum.toString(), size: 5);
//           break;
//         case 'filecoin':
//           var feeNum = (BigInt.parse(gasPremium) + BigInt.parse(gasFeeCap)) * BigInt.from(gasLimit);
//           fee = formatCoin(feeNum.toString(), size: 5);
//           break;
//         case 'ethOthers':
//           var unit = BigInt.from(pow(10, 18));
//           var feeNum = BigInt.parse(gasPrice) * BigInt.from(gasLimit)/unit;
//           fee = formatCoin(feeNum.toString(), size: 5);
//           break;
//         default:
//           fee = '0';
//       }
//       return fee;
//     }catch(error){
//       return '0';
//     }
//
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
//         this.maxFeePerGas = '',
//         this.gasFeeCap = ''
//       }
//       );
//   ChainGas.fromJson(Map<String, dynamic> json) {
//     gasPrice = json['gasPrice'] ?? '0';
//     gasLimit = json['gasLimit'] ?? 0;
//     gasPremium = json['premium'] ?? '0';
//     level = json['level'] ?? 0;
//     rpcType = json['rpcType'] ?? 0;
//     maxPriorityFee = json['maxPriorityFee'] ?? '0';
//     maxFeePerGas = json['maxFeePerGas'];
//     gasFeeCap = json['gasFeeCap'];
//   }
// }
//
//
// class ChainGasAdapter extends TypeAdapter<ChainGas> {
//   @override
//   final int typeId = 12;
//
//   @override
//   ChainGas read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return ChainGas(
//       gasPrice: fields[0] as String,
//       gasPremium: fields[1] as String,
//       gasLimit: fields[2] as int,
//       level: fields[3] as int,
//         rpcType:fields[4] as String,
//         maxPriorityFee:fields[5] as String,
//         maxFeePerGas:fields[6] as String,
//         gasFeeCap:fields[7] as String
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, ChainGas obj) {
//     writer
//       ..writeByte(7)
//       ..writeByte(0)
//       ..write(obj.gasPrice)
//       ..writeByte(1)
//       ..write(obj.gasPremium)
//       ..writeByte(2)
//       ..write(obj.gasLimit)
//       ..writeByte(3)
//       ..write(obj.level)
//       ..writeByte(4)
//       ..write(obj.rpcType)
//       ..writeByte(5)
//       ..write(obj.maxPriorityFee)
//       ..writeByte(6)
//       ..write(obj.maxFeePerGas)
//       ..writeByte(7)
//       ..write(obj.gasFeeCap);
//   }
//
//   @override
//   int get hashCode => typeId.hashCode;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//           other is ChainGasAdapter &&
//               runtimeType == other.runtimeType &&
//               typeId == other.typeId;
// }