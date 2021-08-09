import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';

Future<String> initSharedPreferences() async {
  var initialRoute = mainPage;
  var instance = await SharedPreferences.getInstance();
  Global.store = instance;
  var langCode = instance.getString(StoreKeyLanguage);
  if (langCode != null) {
    Global.langCode = langCode;
  } else {
    Global.langCode = 'en';
  }
  var box = OpenedBox.walletInstance;
  var activeWalletAddr = instance.getString('currentWalletAddress');
  var activeNetwork = instance.getString('activeNetwork');
  var wcSession = instance.getString('wcSession');
  if (wcSession == null) {
    instance.setString('wcSession', '');
  } else {
    Global.wcSession = wcSession;
  }
  if (activeNetwork == null) {
    $store.setNet(Network.filecoinMainNet);
  } else {
    var list =
        Network.supportNets.where((net) => net.rpc == activeNetwork).toList();
    if (list.isNotEmpty) {
      $store.setNet(list[0]);
    } else {
      if (OpenedBox.netInstance.containsKey(activeNetwork)) {
        $store.setNet(OpenedBox.netInstance.get(activeNetwork));
      }else{
        $store.setNet(Network.filecoinMainNet);
      }
    }
  }
  if (activeWalletAddr != null) {
    var wal = box.get('$activeWalletAddr\_${$store.net.rpc}');
    if (wal == null) {
      initialRoute = initLangPage;
    } else {
      $store.setWallet(wal);
    }
  } else {
    initialRoute = initLangPage;
  }
  return initialRoute;
}
