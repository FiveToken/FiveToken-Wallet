import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:math';

import 'package:web3dart/web3dart.dart';

class FilTransferNewPage extends StatefulWidget {
  @override
  State createState() => FilTransferNewPageState();
}

class FilTransferNewPageState extends State<FilTransferNewPage> {
  String balance = '0';
  TextEditingController amountCtrl = TextEditingController();
  TextEditingController addressCtrl = TextEditingController();
  StoreController controller = $store;
  int nonce;
  FocusNode focusNode = FocusNode();
  ChainProvider provider;
  Network net = $store.net;
  ChainGas gas;
  ChainWallet wallet = $store.wal;
  Token token = Global.cacheToken;
  bool loading = false;

  var nonceBoxInstance = OpenedBox.nonceInsance;
  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['to'] != null) {
        addressCtrl.text = Get.arguments['to'];
      }
      if (Get.arguments['token'] != null) {
        this.token = Get.arguments['token'];
      }
    }
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        var to = addressCtrl.text.trim();
        if (isValidChainAddress(to, net)) {
          getGas(to);
        }
      }
    });
    provider = initProvider();
    getGas(wallet.addr);
    getNonce();
  }

  ChainProvider initProvider() {
    if (net.addressType == 'eth') {
      return EthProvider(net);
    } else {
      return FilecoinProvider(net);
    }
  }

  @override
  void dispose() {
    $store.setGas(ChainGas());
    amountCtrl.dispose();
    addressCtrl.dispose();
    provider.dispose();
    super.dispose();
  }

  bool get showSpeed {
    return pendingList.isNotEmpty;
  }

  bool get isToken => token != null;

  List<CacheMessage> get pendingList {
    return OpenedBox.mesInstance.values
        .where((mes) =>
            mes.pending == 1 && mes.from == wallet.addr && mes.rpc == net.rpc)
        .toList();
  }

  Future<bool> getNonce() async {
    var nonce = await provider.getNonce();
    var address = wallet.addr;
    var now = getSecondSinceEpoch();
    if (nonce != -1) {
      this.nonce = nonce;
      var key = '$address\_${net.rpc}';
      if (!nonceBoxInstance.containsKey(key)) {
        nonceBoxInstance.put(key, Nonce(time: now, value: nonce));
      } else {
        Nonce nonceInfo = nonceBoxInstance.get(key);
        var interval = 5 * 60 * 1000;
        if (now - nonceInfo.time > interval) {
          nonceBoxInstance.put(key, Nonce(time: now, value: nonce));
        }
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getGas(String to) async {
    var g = await provider.getGas(to: to, isToken: isToken,token: token);
    if (g.gasPrice != '0') {
      controller.setGas(g);
      this.gas = g;
      return true;
    } else {
      return false;
    }
  }

  void speedup(String private) async {
    if (loading) {
      return;
    }
    pendingList.sort((a, b) {
      if (a.nonce != null && b.nonce != null) {
        return b.nonce.compareTo(a.nonce);
      } else {
        return -1;
      }
    });
    var last = pendingList.last;
    var from = last.from;
    var n = last.nonce;
    var rpc = last.rpc;
    var key = '$from\_$n\_$rpc';
    var cacheGas = OpenedBox.gasInsance.get(key);
    if (cacheGas != null) {
      try {
        var chainPremium = controller.gas.gasPremium;
        var g = provider.replaceGas(cacheGas, chainPremium: chainPremium);
        this.loading = true;
        showCustomLoading('Loading');
        var res = '';
        if (last.token != null) {
          EthProvider p = provider;
          res = await p.sendToken(
              to: last.to,
              nonce: n,
              gas: g,
              amount: last.value,
              private: private,
              addr: token.address);
        } else {
          res = await provider.sendTransaction(
              nonce: n,
              to: last.to,
              amount: last.value,
              gas: g,
              private: private);
        }

        this.loading = false;
        dismissAllToast();
        if (res != '') {
          showCustomToast('sended'.tr);
          controller.setGas(ChainGas());
          OpenedBox.gasInsance.put(key, g);
          OpenedBox.mesInstance.put(
              res,
              CacheMessage(
                  pending: 1,
                  from: from,
                  to: last.to,
                  value: last.value,
                  owner: from,
                  nonce: n,
                  hash: res,
                  rpc: net.rpc,
                  token: token,
                  gas: g,
                  fee: (BigInt.from(g.gasLimit) * BigInt.tryParse(g.gasPrice) ??
                          0)
                      .toString(),
                  blockTime: (DateTime.now().millisecondsSinceEpoch / 1000)
                      .truncate()));
        } else {
          showCustomError('sendFail'.tr);
        }
        if (mounted) {
          goBack();
        }
      } catch (e) {
        this.loading = false;
        dismissAllToast();
        print(e);
      }
    } else {
      showCustomError('sendFail'.tr);
    }
  }

  void pushMsg(String private) async {
    if (loading) {
      return;
    }
    if (!Global.online) {
      showCustomError('errorNet'.tr);
      return;
    }
    var from = wallet.addr;
    var to = addressCtrl.text.trim();
    var amount = amountCtrl.text.trim();
    // if (controller.gas.gasPrice == '0') {
    //   showCustomError('errorSetGas'.tr);
    //   return;
    // }
    // if (nonce == null || nonce == -1) {
    //   showCustomError("errorGetNonce".tr);
    //   return;
    // }
    try {
      var nonceKey = '$from\_${net.rpc}';
      // var realNonce = max(nonce, nonceBoxInstance.get(nonceKey).value);
      var value = getChainValue(amount, precision: token?.precision ?? 18);
      this.loading = true;
      showCustomLoading('Loading');
      if (controller.gas.gasPrice == '0') {
        var valid = await getGas(to);
        if (!valid) {
          showCustomError('errorSetGas'.tr);
          return;
        }
      }
      if (nonce == null || nonce == -1) {
        var valid = await getNonce();
        if (!valid) {
          showCustomError("errorGetNonce".tr);
          return;
        }
      }
      var realNonce = max(nonce, nonceBoxInstance.get(nonceKey).value);
      var res = '';
      if (isToken) {
        EthProvider p = provider;
        res = await p.sendToken(
            to: to,
            nonce: realNonce,
            gas: gas,
            amount: value,
            private: private,
            addr: token.address);
      } else {
        res = await provider.sendTransaction(
          to: to,
          amount: value,
          private: private,
          nonce: realNonce,
          gas: gas,
        );
      }
      this.loading = false;
      dismissAllToast();
      if (res != '') {
        showCustomToast('sended'.tr);
        var cacheGas = ChainGas(
            gasPrice: controller.gas.gasPrice,
            gasLimit: controller.gas.gasLimit,
            gasPremium: controller.gas.gasPremium);
        OpenedBox.gasInsance.put('$from\_$realNonce\_${net.rpc}', cacheGas);
        controller.setGas(ChainGas());
        OpenedBox.mesInstance.put(
            res,
            CacheMessage(
                pending: 1,
                from: from,
                to: to,
                value: value,
                owner: from,
                nonce: realNonce,
                hash: res,
                rpc: net.rpc,
                token: token,
                gas: cacheGas,
                fee: (BigInt.from(cacheGas.gasLimit) *
                            BigInt.tryParse(cacheGas.gasPrice) ??
                        0)
                    .toString(),
                blockTime:
                    (DateTime.now().millisecondsSinceEpoch / 1000).truncate()));
        var oldNonce = nonceBoxInstance.get(nonceKey);
        nonceBoxInstance.put(
            nonceKey, Nonce(value: realNonce + 1, time: oldNonce.time));
      } else {
        showCustomError('sendFail'.tr);
      }
      if (mounted) {
        goBack();
      }
    } catch (e) {
      this.loading = false;
      dismissAllToast();
      showCustomError('sendFail'.tr);
      print(e);
    }
  }

  void goBack() {
    if (Get.previousRoute != null && Get.previousRoute != '') {
      if (Get.previousRoute == mainPage) {
        Get.offAndToNamed(walletMainPage);
      } else {
        Get.back();
      }
    }
  }

  bool checkInputValid() {
    var amount = amountCtrl.text;
    var toAddress = addressCtrl.text;
    var trimAmount = amount.trim();
    var trimAddress = toAddress.trim();
    if (trimAddress == "") {
      showCustomError('enterAddr'.tr);
      return false;
    }
    if (!isValidChainAddress(trimAddress, net)) {
      showCustomError('errorAddr'.tr);
      return false;
    }
    if (trimAddress == $store.wal.addr) {
      showCustomError('errorFromAsTo'.tr);
      return false;
    }
    if (trimAmount == "" || !isDecimal(trimAmount)) {
      showCustomError('enterValidAmount'.tr);
      return false;
    }
    var a = double.parse(trimAmount);
    if (a == 0) {
      showCustomError('enterValidAmount'.tr);
      return false;
    }
    var balanceNum =
        BigInt.tryParse(isToken ? token.balance : controller.wal.balance);
    var fee = controller.gas.feeNum;
    var amountNum = BigInt.from(
        (double.tryParse(trimAmount) * pow(10, isToken ? token.precision : 18))
            .truncate());
    if (isToken) {
      if (amountNum > balanceNum) {
        showCustomError('errorLowBalance'.tr);
        return false;
      }
    } else {
      if (balanceNum < fee + amountNum) {
        showCustomError('errorLowBalance'.tr);
        return false;
      }
    }
    return true;
  }

  String get formatBalance {
    if ($store.net.addressType == 'eth') {
      return EtherAmount.fromUnitAndValue(EtherUnit.wei, balance)
              .getValueInUnit(EtherUnit.ether)
              .toString() +
          ' ' +
          $store.net.coin;
    } else {
      return formatFIL(BigInt.parse(balance).toString());
    }
  }

  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
        .then((scanResult) {
      if (scanResult != '') {
        if (isValidAddress(scanResult)) {
          addressCtrl.text = scanResult;
        } else {
          showCustomError('errorAddr'.tr);
        }
      }
    });
  }

  String get title => token != null ? token.symbol : $store.net.coin;
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      grey: true,
      title: 'send'.tr + title,
      footerText: 'next'.tr,
      actions: [
        Padding(
          child: GestureDetector(
              onTap: handleScan,
              child: Image(
                width: 20,
                image: AssetImage('icons/scan.png'),
              )),
          padding: EdgeInsets.only(right: 10),
        )
      ],
      onPressed: () async {
        if (!checkInputValid()) {
          return;
        }
        var pushNew = () {
          showCustomModalBottomSheet(
              shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
              context: context,
              builder: (BuildContext context) {
                return ConstrainedBox(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 30),
                    child: ConfirmSheet(
                      from: controller.wal.address,
                      to: addressCtrl.text,
                      gas: controller.gas.maxFee,
                      value: amountCtrl.text,
                      token: token,
                      onConfirm: (String ck) {
                        pushMsg(ck);
                      },
                    ),
                  ),
                  constraints: BoxConstraints(maxHeight: 800),
                );
              });
        };
        if (showSpeed) {
          showCustomModalBottomSheet(
              shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
              context: context,
              builder: (BuildContext context) {
                return ConstrainedBox(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 30),
                    child: SpeedupSheet(
                      onNew: pushNew,
                      onSpeedUp: () async {
                        showPassDialog(context, (String pass) async {
                          var wal = $store.wal;
                          var ck =
                              await getPrivateKey(wal.address, pass, wal.skKek);
                          speedup(ck);
                        });
                      },
                    ),
                  ),
                  constraints: BoxConstraints(maxHeight: 800),
                );
              });
        } else {
          pushNew();
        }
      },
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Field(
              controller: addressCtrl,
              label: 'to'.tr,
              focusNode: focusNode,
              extra: GestureDetector(
                child: Padding(
                  child: Image(width: 20, image: AssetImage('icons/book.png')),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onTap: () {
                  Get.toNamed(addressSelectPage).then((value) {
                    if (value is ContactAddress) {
                      addressCtrl.text = value.address;
                    } else if (value is ChainWallet) {
                      addressCtrl.text = value.addr;
                    }
                  });
                },
              ),
            ),
            Field(
              controller: amountCtrl,
              type: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [PrecisionLimitFormatter(8)],
              label: 'amount'.tr,
              append: CommonText(
                token == null
                    ? formatCoin($store.wal.balance)
                    : token.formatBalance,
                color: CustomColor.grey,
              ),
            ),
            GestureDetector(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: CommonText.main('fee'.tr),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                    decoration: BoxDecoration(
                        color: Color(0xff5C8BCB),
                        borderRadius: CustomRadius.b8),
                    child: Row(
                      children: [
                        Obx(() => CommonText(
                              $store.gas.maxFee,
                              size: 14,
                              color: Colors.white,
                            )),
                        Spacer(),
                        CommonText(
                          'advanced'.tr,
                          color: Colors.white,
                          size: 14,
                        ),
                        Image(width: 18, image: AssetImage('icons/right-w.png'))
                      ],
                    ),
                  )
                ],
              ),
              onTap: () {
                Get.toNamed(filGasPage);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SpeedupSheet extends StatelessWidget {
  final Noop onSpeedUp;
  final Noop onNew;
  SpeedupSheet({this.onSpeedUp, this.onNew});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonTitle(
          'sendConfirm'.tr,
          showDelete: true,
        ),
        Container(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText('hasPending'.tr),
                SizedBox(
                  height: 15,
                ),
                TabCard(
                  items: [
                    CardItem(
                      label: 'speedup'.tr,
                      onTap: () {
                        Get.back();
                        onSpeedUp();
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                TabCard(
                  items: [
                    CardItem(
                      label: 'continueNew'.tr,
                      onTap: () {
                        Get.back();
                        onNew();
                      },
                    )
                  ],
                ),
              ],
            ))
      ],
    );
  }
}

class ConfirmSheet extends StatelessWidget {
  final String from;
  final String to;
  final String gas;
  final String value;
  final SingleStringParamFn onConfirm;
  final Widget footer;
  final Token token;
  final EdgeInsets padding = EdgeInsets.symmetric(horizontal: 12, vertical: 14);
  ConfirmSheet(
      {this.from,
      this.to,
      this.gas,
      this.value,
      this.onConfirm,
      this.footer,
      this.token});
  String get symbol => token != null ? token.symbol : $store.net.coin;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonTitle(
          'sendConfirm'.tr,
          showDelete: true,
        ),
        Container(
          color: CustomColor.bgGrey,
          child: Column(
            children: [
              Container(
                padding: padding,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.grey('from'.tr),
                        Container(
                          width: 50,
                        ),
                        Expanded(
                            child: Text(
                          from,
                          textAlign: TextAlign.right,
                        )),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.grey('to'.tr),
                        Container(
                          width: 50,
                        ),
                        Expanded(
                            child: Text(
                          to,
                          textAlign: TextAlign.right,
                        )),
                      ],
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: CustomRadius.b8),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText.grey('amount'.tr),
                    CommonText(
                      '-$value $symbol',
                      size: 18,
                      color: CustomColor.primary,
                      weight: FontWeight.w500,
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: CustomRadius.b8),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [CommonText.grey('fee'.tr), CommonText.main(gas)],
                ),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: CustomRadius.b8),
              ),
              SizedBox(
                height: 30,
              ),
              footer ??
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(const Radius.circular(8)),
                      color: CustomColor.primary,
                    ),
                    child: FlatButton(
                      child: Text(
                        'send'.tr,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                        showPassDialog(context, (String pass) async {
                          var wal = $store.wal;
                          var ck = await wal.getPrivateKey(pass);
                          onConfirm(ck);
                        });
                      },
                      //color: Colors.blue,
                    ),
                  )
            ],
          ),
          padding: EdgeInsets.fromLTRB(12, 15, 12, 20),
        )
      ],
    );
  }
}
