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

  var box = OpenedBox.get<ChainWallet>();
  var activeWalletAddr = instance.getString('currentWalletAddress');
  var activeNetwork = instance.getString('activeNetwork');
  var wcSession = instance.getString('wcSession');
  if (wcSession == null) {
    instance.setString('wcSession', '');
  } else {
    Global.wcSession = wcSession;
  }
  // migrate v1.0.0
  var filList = OpenedBox.get<Wallet>().values;
  var keys = OpenedBox.get<Wallet>().keys;
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
        Global.store.setString('currentWalletAddress', activeWalletAddr);
      }
    }
    OpenedBox.get<ContactAddress>().deleteAll(keys);
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
      if (OpenedBox.get<Network>().containsKey(activeNetwork)) {
        $store.setNet(OpenedBox.get<Network>().get(activeNetwork));
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
