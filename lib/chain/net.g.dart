// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NetworkAdapter extends TypeAdapter<Network> {
  @override
  final int typeId = 7;

  @override
  Network read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Network(
      name: fields[0] as String,
      chain: fields[1] as String,
      net: fields[2] as String,
      netType: fields[7] as int,
      chainId: fields[3] as String,
      rpc: fields[4] as String,
      browser: fields[5] as String,
      addressType: fields[8] as String,
      prefix: fields[9] as String,
      path: fields[10] as String,
      color: fields[11] as String,
      coin: fields[6] as String,
      decimals: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Network obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.chain)
      ..writeByte(2)
      ..write(obj.net)
      ..writeByte(3)
      ..write(obj.chainId)
      ..writeByte(4)
      ..write(obj.rpc)
      ..writeByte(5)
      ..write(obj.browser)
      ..writeByte(6)
      ..write(obj.coin)
      ..writeByte(7)
      ..write(obj.netType)
      ..writeByte(8)
      ..write(obj.addressType)
      ..writeByte(9)
      ..write(obj.prefix)
      ..writeByte(10)
      ..write(obj.path)
      ..writeByte(11)
      ..write(obj.color)
      ..writeByte(12)
      ..write(obj.decimals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
