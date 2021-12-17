// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nonce_unit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NonceUnitAdapter extends TypeAdapter<NonceUnit> {
  @override
  final int typeId = 13;

  @override
  NonceUnit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NonceUnit(
      time: fields[0] as int,
      value: (fields[1] as List)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, NonceUnit obj) {
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
      other is NonceUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
