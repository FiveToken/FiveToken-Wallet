// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gas.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChainGasAdapter extends TypeAdapter<ChainGas> {
  @override
  final int typeId = 12;

  @override
  ChainGas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChainGas(
      gasLimit: fields[2] as int,
      gasPremium: fields[1] as String,
      gasPrice: fields[0] as String,
      level: fields[3] as int,
      rpcType: fields[4] as String,
      maxPriorityFee: fields[5] as String,
      maxFeePerGas: fields[6] as String,
      gasFeeCap: fields[7] as String,
      baseMaxPriorityFee: fields[8] as String,
      baseFeePerGas: fields[9] as String,
      isCustomize: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ChainGas obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.gasPrice)
      ..writeByte(1)
      ..write(obj.gasPremium)
      ..writeByte(2)
      ..write(obj.gasLimit)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.rpcType)
      ..writeByte(5)
      ..write(obj.maxPriorityFee)
      ..writeByte(6)
      ..write(obj.maxFeePerGas)
      ..writeByte(7)
      ..write(obj.gasFeeCap)
      ..writeByte(8)
      ..write(obj.baseMaxPriorityFee)
      ..writeByte(9)
      ..write(obj.baseFeePerGas)
      ..writeByte(10)
      ..write(obj.isCustomize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainGasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
