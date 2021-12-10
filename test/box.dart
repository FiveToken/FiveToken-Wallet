import 'package:fil/chain/net.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';
import 'package:fil/models/address.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';

class MockBox<T> extends Mock implements Box<T> {}

MockBox<Network> mockNetbox() {
  var box = MockBox<Network>();
  // OpenedBox.netInstance = box;
  return box;
}

MockBox<ContactAddress> mockAddressBookBox() {
  var box = MockBox<ContactAddress>();
  // OpenedBox.addressBookInsance = box;
  return box;
}

MockBox<ChainWallet> mockChainWalletBox() {
  var box = MockBox<ChainWallet>();
  // OpenedBox.walletInstance = box;
  return box;
}

MockBox<Token> mockTokenBox() {
  var box = MockBox<Token>();
  // OpenedBox.tokenInstance = box;
  return box;
}
