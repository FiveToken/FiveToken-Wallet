import 'package:fil/index.dart';
import 'package:hive/hive.dart';
part 'cacheMessage.g.dart';

@HiveType(typeId: 11)
class CacheMessage {
  @HiveField(0)
  String from;
  @HiveField(1)
  String to;
  @HiveField(2)
  String owner;
  @HiveField(3)
  String hash;
  @HiveField(4)
  String value;
  @HiveField(5)
  num blockTime;
  @HiveField(6)
  num exitCode;
  @HiveField(7)
  num pending;
  @HiveField(8)
  num nonce;
  @HiveField(9)
  String rpc;
  @HiveField(10)
  ChainGas gas;
  @HiveField(11)
  Token token;
  @HiveField(12)
  String fee;
  @HiveField(13)
  int height;
  @HiveField(14)
  String mid; //only for filecoin
  CacheMessage(
      {this.from = '',
      this.to = '',
      this.hash = '',
      this.value = '0',
      this.blockTime = 0,
      this.owner = '',
      this.pending = 1,
      this.nonce = 0,
      this.rpc = '',
      this.gas,
      this.token,
      this.fee = '',
      this.height = 0,
      this.mid = '',
      this.exitCode});
  String get formatValue {
    if (token != null) {
      return token.getFormatBalance(value);
    } else {
      return formatCoin(value);
    }
  }
}
