import 'package:fil/request/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/chain/contract.dart';
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
  TokenAddPage();
  @override
  State<StatefulWidget> createState() {
    return TokenAddPageState();
  }
}

class TokenAddPageState extends State<TokenAddPage> {
  TextEditingController addrCtrl = TextEditingController();
  TextEditingController symbolCtrl = TextEditingController();
  TextEditingController preCtrl = TextEditingController();
  FocusNode node = FocusNode();
  bool loading = false;
  @override
  void initState() {
    super.initState();
    node.addListener(() async {
      if (!node.hasFocus) {
        var addr = addrCtrl.text.trim();
        bool valid = isValidContractAddress(addr);
        if (valid) {
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
  }

  Future getMetaInfo(String address) async {
    if (this.loading) {
      return;
    }
    this.loading = true;
    showCustomLoading('Loading');
    try {
      Chain.setRpcNetwork($store.net.rpc, $store.net.chain);
      var res = await Chain.chainProvider.getTokenInfo(address);
      dismissAllToast();
      this.loading = false;
      if(res.symbol.isNotEmpty && res.precision != '0'){
        symbolCtrl.text = res.symbol;
        preCtrl.text = res.precision;
      }else{
        showCustomError('searchTokenFail'.tr);
      }
    } catch (e) {
      showCustomError('searchTokenFail'.tr);
      this.loading = false;
      dismissAllToast();
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
      showCustomError('invalidTokenAddr'.tr);
      return;
    }
    if (pre == '') {
      showCustomError('invalidTokenAddr'.tr);
      return;
    }
    OpenedBox.tokenInstance.put(
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
                  bool valid = await isValidChainAddress(addr, $store.net);
                  if (addr != null && valid) {
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
