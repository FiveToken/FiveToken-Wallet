// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoreMessageAdapter extends TypeAdapter<StoreMessage> {
  @override
  final int typeId = 4;

  @override
  StoreMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StoreMessage(
      from: fields[0] as String,
      to: fields[1] as String,
      signedCid: fields[3] as String,
      value: fields[4] as String,
      blockTime: fields[5] as num,
      owner: fields[2] as String,
      pending: fields[7] as num,
      args: fields[8] as String,
      nonce: fields[9] as num,
      exitCode: fields[6] as num,
    );
  }

  @override
  void write(BinaryWriter writer, StoreMessage obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.from)
      ..writeByte(1)
      ..write(obj.to)
      ..writeByte(2)
      ..write(obj.owner)
      ..writeByte(3)
      ..write(obj.signedCid)
      ..writeByte(4)
      ..write(obj.value)
      ..writeByte(5)
      ..write(obj.blockTime)
      ..writeByte(6)
      ..write(obj.exitCode)
      ..writeByte(7)
      ..write(obj.pending)
      ..writeByte(8)
      ..write(obj.args)
      ..writeByte(9)
      ..write(obj.nonce);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
