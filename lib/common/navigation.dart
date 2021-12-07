import 'package:fil/index.dart';

class PushObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route previousRoute) {
    super.didPush(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didRemove(route, previousRoute);
    if (route != null && route.settings.name == walletMainPage) {
      _clearCashToken();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (route != null && route.settings.name == walletMainPage) {
      _clearCashToken();
    }
  }

  void _clearCashToken(){
    Global.cacheToken = null;
  }
}
