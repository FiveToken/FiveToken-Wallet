import 'package:fil/index.dart';
import 'package:hive/hive.dart';
part 'wallet.g.dart';

@HiveType(typeId: 3)
class Wallet {
  @HiveField(0)
  int walletType;
  @HiveField(1)
  String label;
  @HiveField(2)
  String ck;
  @HiveField(3)
  String address;
  @HiveField(4)
  String type;
  @HiveField(5)
  String balance;
  @HiveField(6)
  bool push;
  @HiveField(7)
  String mne;
  @HiveField(8)
  String skKek;
  @HiveField(9)
  String digest;
  Wallet(
      {String ck = '',
      String label = '',
      String address = '',
      String type = '1',
      int walletType = 0,
      String balance = '0',
      bool push = false,
      String mne = '',
      String skKek = '',
      String digest = ''}) {
    this.ck = ck;
    this.label = label;
    this.address = address;
    this.type = type;
    this.walletType = walletType;
    this.balance = balance;
    this.mne = mne;
    this.skKek = skKek;
    this.digest = digest;
    this.push = push;
  }
  String get addr {
    return address;
  }

  String get addrWithNet {
    return Global.netPrefix + addr.substring(1);
  }
}

class CoinPrice {
  double usd;
  double cny;
  CoinPrice({this.usd = 0.0, this.cny = 0.0});
  CoinPrice.fromJson(Map<String, dynamic> json) {
    usd = json['usd'] + 0.0 as double;
    cny = json['cny'] + 0.0 as double;
  }
  double get rate {
    //var lang = Global.langCode;
    var lang = 'en';
    return lang == 'en' ? usd : cny;
  }

  Map<String, double> toJson() {
    return <String, double>{"usd": usd, "cny": cny};
  }
}
