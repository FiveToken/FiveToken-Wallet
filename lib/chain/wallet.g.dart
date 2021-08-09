// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChainWalletAdapter extends TypeAdapter<ChainWallet> {
  @override
  final int typeId = 9;

  @override
  ChainWallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChainWallet(
      ck: fields[1] as String,
      label: fields[0] as String,
      address: fields[2] as String,
      type: fields[3] as int,
      balance: fields[4] as String,
      mne: fields[5] as String,
      skKek: fields[6] as String,
      digest: fields[7] as String,
      groupHash: fields[8] as String,
      rpc: fields[10] as String,
      addressType: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChainWallet obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.ck)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.balance)
      ..writeByte(5)
      ..write(obj.mne)
      ..writeByte(6)
      ..write(obj.skKek)
      ..writeByte(7)
      ..write(obj.digest)
      ..writeByte(8)
      ..write(obj.groupHash)
      ..writeByte(9)
      ..write(obj.addressType)
      ..writeByte(10)
      ..write(obj.rpc);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainWalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
