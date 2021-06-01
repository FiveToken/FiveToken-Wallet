import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fil/index.dart';

const messageBox = 'message';
const addressBox = 'address';
const addressBookBox = 'addressBook';
const nonceBox = 'nonceBox';
const gasBox = 'gasBox';
Future initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(StoreMessageAdapter());
  Hive.registerAdapter(NonceAdapter());
  Hive.registerAdapter(CacheGasAdapter());
  await Hive.openBox<StoreMessage>(messageBox);
  await Hive.openBox<Wallet>(addressBox);
  await Hive.openBox<Wallet>(addressBookBox);
  await Hive.openBox<Nonce>(nonceBox);
  await Hive.openBox<CacheGas>(gasBox);
}

class OpenedBox {
  static Box<StoreMessage> get messageInsance {
    return Hive.box<StoreMessage>(messageBox);
  }

  static Box<Wallet> get addressInsance {
    return Hive.box<Wallet>(addressBox);
  }

  static Box<Wallet> get addressBookInsance {
    return Hive.box<Wallet>(addressBookBox);
  }

  static Box<Nonce> get nonceInsance {
    return Hive.box<Nonce>(nonceBox);
  }

  static Box<CacheGas> get gasInsance {
    return Hive.box<CacheGas>(gasBox);
  }
}
