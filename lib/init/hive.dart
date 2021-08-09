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
  Hive.registerAdapter(StoreMessageAdapter());
  Hive.registerAdapter(NonceAdapter());
  Hive.registerAdapter(CacheGasAdapter());
  Hive.registerAdapter(NetworkAdapter());
  Hive.registerAdapter(TokenAdapter());
  Hive.registerAdapter(ChainWalletAdapter());
  Hive.registerAdapter(ContactAddressAdapter());
  Hive.registerAdapter(CacheMessageAdapter());
  Hive.registerAdapter(ChainGasAdapter());
  await Hive.openBox<StoreMessage>(messageBox);
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
  // await OpenedBox.mesInstance.deleteFromDisk();
  // await OpenedBox.tokenInstance.deleteFromDisk();
}

class OpenedBox {
  static Box<StoreMessage> get messageInsance {
    return Hive.box<StoreMessage>(messageBox);
  }

  static Box<Wallet> get addressInsance {
    return Hive.box<Wallet>(addressBox);
  }

  static Box<ContactAddress> get addressBookInsance {
    return Hive.box<ContactAddress>(addressBookBox);
  }

  static Box<Nonce> get nonceInsance {
    return Hive.box<Nonce>(nonceBox);
  }

  static Box<ChainGas> get gasInsance {
    return Hive.box<ChainGas>(gasBox);
  }

  static Box<Network> get netInstance {
    return Hive.box<Network>(netBox);
  }

  static Box<Token> get tokenInstance {
    return Hive.box<Token>(tokenBox);
  }

  static Box<ChainWallet> get walletInstance {
    return Hive.box<ChainWallet>(walletBox);
  }

  static Box<CacheMessage> get mesInstance {
    return Hive.box<CacheMessage>(cacheMessageBox);
  }
}
