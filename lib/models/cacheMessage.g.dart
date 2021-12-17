// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cacheMessage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CacheMessageAdapter extends TypeAdapter<CacheMessage> {
  @override
  final int typeId = 11;

  @override
  CacheMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheMessage(
      from: fields[0] as String,
      to: fields[1] as String,
      hash: fields[3] as String,
      value: fields[4] as String,
      blockTime: fields[5] as num,
      owner: fields[2] as String,
      pending: fields[7] as num,
      nonce: fields[8] as num,
      rpc: fields[9] as String,
      gas: fields[10] as ChainGas,
      token: fields[11] as Token,
      fee: fields[12] as String,
      height: fields[13] as int,
      mid: fields[14] as String,
      symbol: fields[15] as String,
      exitCode: fields[6] as num,
    );
  }

  @override
  void write(BinaryWriter writer, CacheMessage obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.from)
      ..writeByte(1)
      ..write(obj.to)
      ..writeByte(2)
      ..write(obj.owner)
      ..writeByte(3)
      ..write(obj.hash)
      ..writeByte(4)
      ..write(obj.value)
      ..writeByte(5)
      ..write(obj.blockTime)
      ..writeByte(6)
      ..write(obj.exitCode)
      ..writeByte(7)
      ..write(obj.pending)
      ..writeByte(8)
      ..write(obj.nonce)
      ..writeByte(9)
      ..write(obj.rpc)
      ..writeByte(10)
      ..write(obj.gas)
      ..writeByte(11)
      ..write(obj.token)
      ..writeByte(12)
      ..write(obj.fee)
      ..writeByte(13)
      ..write(obj.height)
      ..writeByte(14)
      ..write(obj.mid)
      ..writeByte(15)
      ..write(obj.symbol);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
