import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:fil/chain/token.dart';
import 'package:fil/chain/contract.dart';
// import 'package:fil/index.dart';
import 'package:oktoast/oktoast.dart';
import 'package:web3dart/web3dart.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/services.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/common/formatter.dart';

class TokenAddPage extends StatefulWidget {
  final Web3Client defaultClient;
  TokenAddPage({this.defaultClient});
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
    client = widget.defaultClient ?? Web3Client($store.net.url, http.Client());
    node.addListener(() {
      if (!node.hasFocus) {
        var addr = addrCtrl.text.trim();
        if (isValidEthAddress(addr)) {
          getMetaInfo(addr);
        } else {
          showCustomError('invalidTokenAddr'.tr);
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
        } else {
          showCustomError('invalidTokenAddr'.tr);
        }
      }
    } catch (e) {
      print(e);
      this.loading = false;
      dismissAllToast();
      showCustomError('searchTokenFail'.tr);
    }
  }

  void submit() async {
    var addr = addrCtrl.text.trim();
    var symbol = symbolCtrl.text.trim();
    var pre = preCtrl.text.trim();
    if (addr == '') {
      showCustomError('enterTokenAddr'.tr);
      return;
    }
    if (symbol == '') {
      showCustomError('enterTokenSymbol'.tr);
      return;
    }
    if (pre == '') {
      showCustomError('enterTokenPre'.tr);
      return;
    }
    OpenedBox.get<Token>().put(
        addr + $store.net.rpc,
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
      title: 'addToken'.tr,
      footerText: 'add'.tr,
      onPressed: () {
        submit();
      },
      grey: true,
      body: Padding(
        child: Column(
          children: [
            Field(
              label: 'tokenAddr'.tr,
              append: GestureDetector(
                child: Image(width: 20, image: AssetImage('icons/cop.png')),
                onTap: () async {
                  var data = await Clipboard.getData(Clipboard.kTextPlain);
                  var addr = data.text;
                  if (addr != null && isValidChainAddress(addr, $store.net)) {
                    addrCtrl.text = addr;
                    getMetaInfo(addr);
                  }
                },
              ),
              controller: addrCtrl,
              placeholder: '0x...',
              focusNode: node,
            ),
            Field(
              label: 'tokenSymbol'.tr,
              enabled: false,
              controller: symbolCtrl,
            ),
            Field(
              label: 'tokenPre'.tr,
              enabled: false,
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
