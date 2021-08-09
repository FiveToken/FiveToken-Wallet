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
      showCustomError('请输入网络名称');
      return;
    }
    if (rpc == '') {
      showCustomError('请输入rpc地址');
      return;
    }
    if (symbol == '') {
      showCustomError('请输入网络代币名称');
      return;
    }
    if ((Network.supportNets.map((net) => net.rpc).contains(rpc) ||
            OpenedBox.netInstance.containsKey(rpc)) &&
        !edit) {
      showCustomError('当前网络已添加，请不要重复添加');
      return;
    }
    client = Web3Client(rpc, http.Client());
    if (this.loading) {
      return;
    }
    this.loading = true;

    try {
      showCustomLoading('Loading');
      var id = await client.getNetworkId();
      this.loading = false;
      dismissAllToast();
      if (id.toString() != chain) {
        showCustomError('链ID错误');
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
      showCustomError('无效的RPC URL');
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
      title: edit ? '编辑网络' : '网络',
      footerText: '添加',
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
                    text: '删除网络',
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
                    text: '修改网络',
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
            CommonText('新的RPC网络'),
            CommonText('通过URL使用支持自定义RPC的网络，而不是所提供的网络之一'),
            Field(
              label: '网络名称',
              placeholder: '网络名称',
              controller: nameCtrl,
              enabled: !readonly,
            ),
            Field(
              label: 'RPC URL',
              placeholder: '新RPC网络',
              controller: rpcCtrl,
            ),
            Field(
              label: '链 ID',
              placeholder: '链 ID （可选）',
              controller: chainCtrl,
              enabled: !readonly,
            ),
            Field(
              label: '符号',
              placeholder: '当前网络的代币',
              controller: symbolCtrl,
              enabled: !readonly,
            ),
            Field(
              label: '区块链浏览器URL',
              placeholder: '区块链浏览器URL（可选）',
              controller: browserCtrl,
              enabled: !readonly,
            ),
          ],
        ),
      ),
    );
  }
}
