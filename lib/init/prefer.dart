import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';

Future<String> initSharedPreferences() async {
  var initialRoute = mainPage;
  var instance = await SharedPreferences.getInstance();
  Global.store = instance;

  /// If the the app was opened for the first time, English is preferred.
  /// If there is a cached lang code in device, set language to that
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
  // migrate v1.0.0
  var filList = OpenedBox.addressInsance.values;
  var keys = OpenedBox.addressInsance.keys;
  if (filList.isNotEmpty) {
    var net = Network.filecoinMainNet;
    for (var wal in filList) {
      var newWal = ChainWallet(
          label: wal.label,
          skKek: wal.skKek,
          digest: wal.digest,
          type: wal.mne == '' ? 2 : 1,
          groupHash: '',
          mne: wal.mne,
          addressType: net.addressType,
          rpc: net.rpc,
          address: wal.addrWithNet);
      await box.put(newWal.key, newWal);
      if (activeWalletAddr == wal.addrWithNet) {
        activeWalletAddr = newWal.key;
      }
    }
    OpenedBox.addressInsance.deleteAll(keys);
    $store.setNet(net);
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
      } else {
        $store.setNet(Network.filecoinMainNet);
      }
    }
  }
  if (activeWalletAddr != null) {
    var wal = box.get(activeWalletAddr);
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
