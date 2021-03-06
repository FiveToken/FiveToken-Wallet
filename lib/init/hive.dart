import 'package:fil/chain/net.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/chain/wallet.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fil/index.dart';

const messageBox = 'message';
const addressBox = 'address';
const addressBookBox = 'addressBookBox';
const nonceBox = 'nonceBox';
const gasBox = 'gasBox';
const netBox = 'netBox';
const tokenBox = 'tokenBox';
const walletBox = 'walletBox';
const cacheMessageBox = 'cacheMessageBox';
Future initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(NonceAdapter());
  Hive.registerAdapter(CacheGasAdapter());
  Hive.registerAdapter(NetworkAdapter());
  Hive.registerAdapter(TokenAdapter());
  Hive.registerAdapter(ChainWalletAdapter());
  Hive.registerAdapter(ContactAddressAdapter());
  Hive.registerAdapter(CacheMessageAdapter());
  Hive.registerAdapter(ChainGasAdapter());
  await Hive.openBox<Wallet>(addressBox);
  await Hive.openBox<ContactAddress>(addressBookBox);
  await Hive.openBox<Nonce>(nonceBox);
  await Hive.openBox<ChainGas>(gasBox);
  await Hive.openBox<Network>(netBox);
  await Hive.openBox<Token>(tokenBox);
  await Hive.openBox<ChainWallet>(walletBox);
  await Hive.openBox<CacheMessage>(cacheMessageBox);
  // await OpenedBox.walletInstance.deleteFromDisk();
  // await OpenedBox.mesInstance.deleteFromDisk();
  // await OpenedBox.tokenInstance.deleteFromDisk();
  OpenedBox.initBox();
}

class OpenedBox {
  static Box<Wallet> addressInsance;
  static Box<ContactAddress> addressBookInsance;
  static Box<Nonce> nonceInsance;

  static Box<ChainGas> gasInsance;

  static Box<Network> netInstance;

  static Box<Token> tokenInstance;

  static Box<ChainWallet> walletInstance;

  static Box<CacheMessage> mesInstance;

  static void initBox() {
    OpenedBox.addressInsance = Hive.box<Wallet>(addressBox);
    OpenedBox.addressBookInsance = Hive.box<ContactAddress>(addressBookBox);
    OpenedBox.nonceInsance = Hive.box<Nonce>(nonceBox);
    OpenedBox.gasInsance = Hive.box<ChainGas>(gasBox);
    OpenedBox.netInstance = Hive.box<Network>(netBox);
    OpenedBox.tokenInstance = Hive.box<Token>(tokenBox);
    OpenedBox.walletInstance = Hive.box<ChainWallet>(walletBox);
    OpenedBox.mesInstance = Hive.box<CacheMessage>(cacheMessageBox);
  }
}
