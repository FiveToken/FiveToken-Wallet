import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';
import 'package:oktoast/oktoast.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class NetAddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NetAddPageState();
  }
}

class NetAddPageState extends State<NetAddPage> {
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController rpcCtrl = TextEditingController();
  TextEditingController chainCtrl = TextEditingController();
  TextEditingController symbolCtrl = TextEditingController();
  TextEditingController browserCtrl = TextEditingController();
  Network net;
  Web3Client client;
  bool readonly = false;
  bool loading = false;
  var box = OpenedBox.netInstance;
  void submit() async {
    var name = nameCtrl.text.trim();
    var rpc = rpcCtrl.text.trim();
    var chain = chainCtrl.text.trim();
    var symbol = symbolCtrl.text.trim();
    var browser = browserCtrl.text.trim();
    if (name == '') {
      showCustomError('enterNet'.tr);
      return;
    }
    if (rpc == '') {
      showCustomError('enterRpc'.tr);
      return;
    }
    if (symbol == '') {
      showCustomError('enterTokenName'.tr);
      return;
    }
    if ((Network.supportNets.map((net) => net.rpc).contains(rpc) ||
            OpenedBox.netInstance.containsKey(rpc)) &&
        !edit) {
      showCustomError('netExist'.tr);
      return;
    }
    client = Web3Client(rpc, http.Client());
    if (this.loading) {
      return;
    }
    if (browser != '' && browser[browser.length - 1] == '/') {
      browser = browser.substring(0, browser.length - 1);
    }
    this.loading = true;

    try {
      showCustomLoading('Loading');
      var id = await client.getNetworkId();
      this.loading = false;
      dismissAllToast();
      if (id.toString() != chain) {
        showCustomError('errorChainId'.tr);
        return;
      }
      if (edit && net.rpc != rpc) {
        box.delete(net.rpc);
      }
      //add id wallet for new network
      var wallets = OpenedBox.walletInstance.values
          .where((wal) => wal.type == 0 && wal.addressType == 'eth')
          .toList();
      Map<String, ChainWallet> map = {};
      for (var wallet in wallets) {
        map[wallet.groupHash] = wallet;
      }
      map.forEach((key, value) {
        var wal = value.copyWith();
        wal.rpc = rpc;
        OpenedBox.walletInstance.put(wal.key, wal);
      });
      box.put(
          rpc,
          Network(
              name: name,
              addressType: 'eth',
              rpc: rpc,
              netType: 2,
              browser: browser,
              chainId: chain,
              coin: symbol));
      Get.back();
    } catch (e) {
      dismissAllToast();
      showCustomError('invalidRpc'.tr);
    }
  }

  bool get edit => net != null && net.netType == 2;
  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments['net'] != null) {
      net = Get.arguments['net'] as Network;
      readonly = net.netType != 2;
      nameCtrl.text = net.label;
      browserCtrl.text = net.browser;
      symbolCtrl.text = net.coin;
      chainCtrl.text = net.chainId;
      rpcCtrl.text = net.rpc;
    }
  }

  @override
  void dispose() {
    super.dispose();
    client?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var kH = MediaQuery.of(context).viewInsets.bottom;
    return CommonScaffold(
      grey: true,
      title: edit ? 'editNet'.tr : 'net'.tr,
      footerText: 'add'.tr,
      onPressed: submit,
      hasFooter: kH == 0 && (net == null || net.netType == 2),
      resizeToAvoidBottomInset: kH != 0,
      footer: edit
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                      child: FButton(
                    height: 45,
                    strokeColor: Colors.grey[200],
                    corner: FCorner.all(6),
                    alignment: Alignment.center,
                    text: 'deleteNet'.tr,
                    color: Colors.white,
                    style: TextStyle(color: Colors.black),
                    onPressed: () {
                      OpenedBox.netInstance.delete(net.rpc);
                      Get.back();
                    },
                  )),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: FButton(
                    height: 45,
                    corner: FCorner.all(6),
                    alignment: Alignment.center,
                    color: CustomColor.primary,
                    style: TextStyle(color: Colors.white),
                    text: 'changeNet'.tr,
                    onPressed: submit,
                  )),
                ],
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText('newRpc'.tr),
            CommonText('byRpc'.tr),
            Field(
              label: 'netName'.tr,
              placeholder: 'netName'.tr,
              controller: nameCtrl,
              enabled: !readonly,
            ),
            Field(
              label: 'RPC URL',
              placeholder: 'newRpc'.tr,
              controller: rpcCtrl,
            ),
            Field(
              label: 'chainId'.tr,
              placeholder: 'chainId'.tr,
              controller: chainCtrl,
              enabled: !readonly,
            ),
            Field(
              label: 'symbol'.tr,
              placeholder: 'curNetToken'.tr,
              controller: symbolCtrl,
              enabled: !readonly,
            ),
            Field(
              label: 'browser'.tr,
              placeholder: 'browserOptional'.tr,
              controller: browserCtrl,
              enabled: !readonly,
            ),
          ],
        ),
      ),
    );
  }
}
