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
    );
  }

  @override
  void write(BinaryWriter writer, ChainGas obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.gasPrice)
      ..writeByte(1)
      ..write(obj.gasPremium)
      ..writeByte(2)
      ..write(obj.gasLimit)
      ..writeByte(3)
      ..write(obj.level);
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
