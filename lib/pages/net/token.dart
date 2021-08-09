import 'package:http/http.dart' as http;

import 'package:fil/chain/token.dart';
import 'package:fil/index.dart';
import 'package:oktoast/oktoast.dart';
import 'package:web3dart/web3dart.dart';

class TokenAddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TokenAddPageState();
  }
}

class TokenAddPageState extends State<TokenAddPage> {
  TextEditingController addrCtrl = TextEditingController();
  TextEditingController symbolCtrl = TextEditingController();
  TextEditingController preCtrl = TextEditingController();
  Web3Client client;
  FocusNode node = FocusNode();
  bool loading = false;
  @override
  void initState() {
    super.initState();
    client = Web3Client($store.net.rpc, http.Client());
    node.addListener(() {
      if (!node.hasFocus) {
        var addr = addrCtrl.text.trim();
        if (isValidEthAddress(addr)) {
          getMetaInfo(addr);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    client.dispose();
  }

  Future getMetaInfo(String addr) async {
    if (this.loading) {
      return;
    }
    this.loading = true;
    showCustomLoading('Loading');
    var abi = ContractAbi.fromJson(Contract.abi, 'bnb');
    var con = DeployedContract(abi, EthereumAddress.fromHex(addr));
    try {
      var lists = await Future.wait([
        client
            .call(contract: con, function: con.function('symbol'), params: []),
        client
            .call(contract: con, function: con.function('decimals'), params: [])
      ]);
      dismissAllToast();
      this.loading = false;
      if (lists.isNotEmpty) {
        var symbol = lists[0];
        var decimals = lists[1];
        if (symbol.isNotEmpty && decimals.isNotEmpty) {
          symbolCtrl.text = symbol[0].toString();
          preCtrl.text = decimals[0].toString();
        }
      }
    } catch (e) {
      this.loading = false;
      dismissAllToast();
      showCustomError('查询代币信息失败');
    }
  }

  void submit() async {
    var addr = addrCtrl.text.trim();
    var symbol = symbolCtrl.text.trim();
    var pre = preCtrl.text.trim();
    if (addr == '') {
      showCustomError('请输入合约地址');
      return;
    }
    if (symbol == '') {
      showCustomError('请输入代币符号');
      return;
    }
    if (pre == '') {
      showCustomError('请输入代币精度');
      return;
    }
    OpenedBox.tokenInstance.put(
        addr,
        Token(
            symbol: symbolCtrl.text,
            precision: int.parse(preCtrl.text),
            address: addr,
            rpc: $store.net.rpc,
            chain: $store.net.chain));
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '添加代币',
      footerText: 'add'.tr,
      onPressed: () {
        submit();
        // getMetaInfo('addr');
      },
      grey: true,
      body: Padding(
        child: Column(
          children: [
            Field(
              label: '合约地址',
              controller: addrCtrl,
              placeholder: '0x...',
              focusNode: node,
            ),
            Field(
              label: '代币符号',
              controller: symbolCtrl,
            ),
            Field(
              label: '代币精度',
              type: TextInputType.number,
              inputFormatters: [PrecisionLimitFormatter(8)],
              controller: preCtrl,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 20,
        ),
      ),
    );
  }
}
