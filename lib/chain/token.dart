import 'package:fil/index.dart';
part 'token.g.dart';

@HiveType(typeId: 8)
class Token {
  @HiveField(0)
  String symbol;
  @HiveField(1)
  int precision;
  @HiveField(2)
  String address;
  @HiveField(3)
  String chain;
  @HiveField(4)
  String rpc;
  @HiveField(5)
  String balance;
  String get formatBalance => getFormatBalance(balance);

  String getFormatBalance(String b) {
    try {
      var unit = BigInt.from(pow(10, precision));
      var balanceNum = BigInt.parse(b);
      return '${truncate(balanceNum / unit)} $symbol';
    } catch (e) {
      return '';
    }
  }

  Token(
      {this.symbol = '',
      this.precision = 18,
      this.address = '',
      this.chain = '',
      this.rpc = '',
      this.balance = '0'});
}
