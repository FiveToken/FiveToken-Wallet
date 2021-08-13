import 'package:event_bus/event_bus.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';

const StoreKeyLanguage = "language";
const InfoKeyWebUrl = "webUrl";
const InfoKeyWebTitle = "webTitle";

const SignSecp = "secp";
const SignBls = "bls";
const SignTypeBls = 2;
const SignTypeSecp = 1;
const String NetPrefix = 'f';

class Global {
  static String version = "v1.0.0";
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");
  static SharedPreferences store;
  static Wallet activeWallet;
  static ChainWallet cacheWallet;
  static Map<String, dynamic> info = {};
  static String selectWalletType = '1';
  static String uuid;
  static bool online = true;
  static String platform;
  static String os;
  static String currentWalletAddress;
  static CoinPrice price;
  static String langCode;
  static EventBus eventBus = EventBus();
  static String get netPrefix => NetPrefix;
  static String wcSession;
  static Token cacheToken;
}
