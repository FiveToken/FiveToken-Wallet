// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lock.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LockBoxAdapter extends TypeAdapter<LockBox> {
  @override
  final int typeId = 15;

  @override
  LockBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LockBox(
      lockscreen: fields[0] as bool,
      password: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LockBox obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.lockscreen)
      ..writeByte(1)
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LockBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
