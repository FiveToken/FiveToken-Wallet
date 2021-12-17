// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nonce.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NonceAdapter extends TypeAdapter<Nonce> {
  @override
  final int typeId = 5;

  @override
  Nonce read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Nonce(
      time: fields[0] as int,
      value: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Nonce obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NonceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CacheGasAdapter extends TypeAdapter<CacheGas> {
  @override
  final int typeId = 6;

  @override
  CacheGas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheGas(
      feeCap: fields[0] as String,
      premium: fields[1] as String,
      cid: fields[2] as String,
      gasLimit: fields[3] as num,
    );
  }

  @override
  void write(BinaryWriter writer, CacheGas obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.feeCap)
      ..writeByte(1)
      ..write(obj.premium)
      ..writeByte(2)
      ..write(obj.cid)
      ..writeByte(3)
      ..write(obj.gasLimit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheGasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
