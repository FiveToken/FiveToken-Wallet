// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactAddressAdapter extends TypeAdapter<ContactAddress> {
  @override
  final int typeId = 10;

  @override
  ContactAddress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactAddress(
      label: fields[0] as String,
      address: fields[1] as String,
      rpc: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ContactAddress obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.rpc);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactAddressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
