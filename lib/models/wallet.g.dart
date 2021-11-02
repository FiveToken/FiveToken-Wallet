// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 3;

  @override
  Wallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wallet(
      ck: fields[2] as String,
      label: fields[1] as String,
      address: fields[3] as String,
      type: fields[4] as String,
      walletType: fields[0] as int,
      balance: fields[5] as String,
      push: fields[6] as bool,
      mne: fields[7] as String,
      skKek: fields[8] as String,
      digest: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.walletType)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.ck)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.balance)
      ..writeByte(6)
      ..write(obj.push)
      ..writeByte(7)
      ..write(obj.mne)
      ..writeByte(8)
      ..write(obj.skKek)
      ..writeByte(9)
      ..write(obj.digest);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
