// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TMessageAdapter extends TypeAdapter<TMessage> {
  @override
  final int typeId = 1;

  @override
  TMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TMessage(
      version: fields[6] as num,
      to: fields[0] as String,
      from: fields[1] as String,
      value: fields[2] as String,
      gasFeeCap: fields[3] as String,
      gasPremium: fields[5] as String,
      gasLimit: fields[9] as num,
      params: fields[4] as String,
      nonce: fields[7] as num,
      args: fields[10] as String,
      method: fields[8] as num,
    );
  }

  @override
  void write(BinaryWriter writer, TMessage obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.to)
      ..writeByte(1)
      ..write(obj.from)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.gasFeeCap)
      ..writeByte(4)
      ..write(obj.params)
      ..writeByte(5)
      ..write(obj.gasPremium)
      ..writeByte(6)
      ..write(obj.version)
      ..writeByte(7)
      ..write(obj.nonce)
      ..writeByte(8)
      ..write(obj.method)
      ..writeByte(9)
      ..write(obj.gasLimit)
      ..writeByte(10)
      ..write(obj.args);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SignatureAdapter extends TypeAdapter<Signature> {
  @override
  final int typeId = 2;

  @override
  Signature read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Signature(
      fields[1] as num,
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Signature obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.data)
      ..writeByte(1)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignatureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SignedMessageAdapter extends TypeAdapter<SignedMessage> {
  @override
  final int typeId = 0;

  @override
  SignedMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SignedMessage(
      fields[0] as TMessage,
      fields[1] as Signature,
    );
  }

  @override
  void write(BinaryWriter writer, SignedMessage obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.message)
      ..writeByte(1)
      ..write(obj.signature);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignedMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
