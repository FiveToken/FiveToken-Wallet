import 'package:fil/chain/token.dart';

class AppStateChangeEvent {}

class RefreshEvent {
  Token token;
  RefreshEvent({this.token});
}

class WalletChangeEvent {}

class NetChangeEvent {}

class ShouldRefreshEvent {}
