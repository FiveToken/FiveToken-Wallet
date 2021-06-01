import 'package:fil/index.dart';
const StoreKeyLanguage = "language";
const InfoKeyWebUrl = "webUrl";
const InfoKeyWebTitle = "webTitle";

const SignSecp = "secp";
const SignBls = "bls";
const SignTypeBls = 2;
const SignTypeSecp = 1;
const String NetPrefix = 't';
class Global {
  static String version = "v1.0.0";
  // kv store

  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  static SharedPreferences store;

  static Wallet activeWallet;
  static Wallet cacheWallet;
  static Map<String, dynamic> info = {};
  static String selectWalletType = '1';
  static String uuid;
  static bool online = false;
  static String platform;
  static String os;
  static String currentWalletAddress;
  static FilPrice price;
  static String langCode;
  static String get netPrefix => NetPrefix;
  static String wcSession;
}
