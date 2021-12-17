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
      label: fields[0] as String,
      address: fields[1] as String,
      type: fields[2] as int,
      balance: fields[3] as String,
      mne: fields[4] as String,
      skKek: fields[5] as String,
      digest: fields[6] as String,
      groupHash: fields[7] as String,
      rpc: fields[9] as String,
      addressType: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChainWallet obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.mne)
      ..writeByte(5)
      ..write(obj.skKek)
      ..writeByte(6)
      ..write(obj.digest)
      ..writeByte(7)
      ..write(obj.groupHash)
      ..writeByte(8)
      ..write(obj.addressType)
      ..writeByte(9)
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
