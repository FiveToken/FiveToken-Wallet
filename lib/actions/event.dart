import 'package:fil/index.dart';

class AppStateChangeEvent {}
class RefreshEvent{
  Token token;
  RefreshEvent({this.token});
}
class WalletChangeEvent{}
class NetChangeEvent{}
class ShouldRefreshEvent{}