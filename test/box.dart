import 'package:fil/index.dart';
import 'package:mockito/mockito.dart';

class MockBox<T> extends Mock implements Box<T> {}

MockBox<Network> mockNetbox() {
  var box = MockBox<Network>();
  // OpenedBox.get<Network>() = box;
  return box;
}

MockBox<ContactAddress> mockAddressBookBox() {
  var box = MockBox<ContactAddress>();
  // OpenedBox.addressBookInsance = box;
  return box;
}

MockBox<ChainWallet> mockChainWalletBox() {
  var box = MockBox<ChainWallet>();
  // OpenedBox.get<ChainWallet>() = box;
  return box;
}

MockBox<Token> mockTokenBox() {
  var box = MockBox<Token>();
  // OpenedBox.get<Token>() = box;
  return box;
}
