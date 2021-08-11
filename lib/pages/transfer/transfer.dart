import 'package:fil/index.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/index.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:math';

import 'package:oktoast/oktoast.dart';
/// transfer page
class FilTransferNewPage extends StatefulWidget {
  @override
  State createState() => FilTransferNewPageState();
}

class FilTransferNewPageState extends State<FilTransferNewPage>
    with RouteAware {
  String balance;
  TextEditingController _amountCtl = TextEditingController();
  TextEditingController _addressCtl = TextEditingController();
  StoreController controller = singleStoreController;
  int nonce;
  FocusNode focusNode = FocusNode();
  FocusNode focusNode2 = FocusNode();
  Timer timer;
  var nonceBoxInstance = Hive.box<Nonce>(nonceBox);
  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments['to'] != null) {
      _addressCtl.text = Get.arguments['to'];
    }
    getGas();
    _getNonce();
    _addressCtl.addListener(() {
      timer?.cancel();
      timer = Timer(Duration(milliseconds: 300), () {
        checkInputToGetGas();
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    super.didPopNext();
    setState(() {});
  }

  @override
  void dispose() {
    singleStoreController.setGas(Gas());
    timer?.cancel();
    _amountCtl.dispose();
    _addressCtl.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  bool get showSpeed {
    var pendingList =
        OpenedBox.messageInsance.values.where((mes) => mes.pending == 1);
    return pendingList.isNotEmpty;
  }
  /// get suggest gas 
  Future getGas() async {
    var to = _addressCtl.text.trim();
    var res = await getGasDetail(to: to);
    if (res.feeCap != '0') {
      controller.setGas(res);
      setState(() {});
    }
  }
  /// increase gas and resend a blocked message
  void speedup(String ck) async {
    var pendingList = OpenedBox.messageInsance.values
        .where((mes) => mes.pending == 1)
        .toList();
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
    var key = '$from\_$n';
    var cacheGas = OpenedBox.gasInsance.get(key);
    if (cacheGas != null) {
      /// increase GasPremium to replace the message in mpool
      var chainPremium = int.parse(controller.gas.value.premium);
      var caculatePremium = (int.parse(cacheGas.premium) * 1.3).truncate();
      var realPremium = max(chainPremium, caculatePremium);
      var msg = TMessage(
          version: 0,
          method: 0,
          nonce: n,
          from: from,
          to: last.to,
          params: "",
          value: last.value,
          gasFeeCap: controller.gas.value.feeCap,
          gasLimit: controller.gas.value.gasLimit,
          gasPremium: realPremium.toString());
      String sign = '';
      num signType;
      var cid = await Flotus.messageCid(msg: jsonEncode(msg));
      if (controller.wal.type == '1') {
        signType = SignTypeSecp;
        sign = await Flotus.secpSign(ck: ck, msg: cid);
      } else {
        signType = SignTypeBls;
        sign = await Bls.cksign(num: "$ck $cid");
      }
      var sm = SignedMessage(msg, Signature(signType, sign));
      showCustomLoading('sending'.tr);
      String res = await pushSignedMsg(sm.toLotusSignedMessage());
      dismissAllToast();
      if (res != '') {
        showCustomToast('sended'.tr);
        controller.setGas(Gas());
        var newCacheGas = CacheGas(
            cid: res,
            feeCap: controller.gas.value.feeCap,
            gasLimit: controller.gas.value.gasLimit,
            premium: controller.gas.value.premium);
        OpenedBox.gasInsance.put('$from\_$n', newCacheGas);
        Hive.box<StoreMessage>(messageBox).put(
            res,
            StoreMessage(
                pending: 1,
                from: from,
                to: last.to,
                value: last.value,
                owner: from,
                nonce: n,
                signedCid: res,
                blockTime:
                    (DateTime.now().millisecondsSinceEpoch / 1000).truncate()));
      } else {
        showCustomError('sendFail'.tr);
      }
      if (mounted) {
        Get.back();
      }
    }
  }
  /// push message 
  void _pushMsg(String ck) async {
    if (!Global.online) {
      showCustomError('errorNet'.tr);
      return;
    }
    var from = controller.wal.addrWithNet;
    var to = _addressCtl.text.trim();
    if (controller.gas.value.feeCap == '0') {
      showCustomError('errorSetGas'.tr);
    }
    //var a = double.parse(_amountCtl.text.trim());
    if (nonce == null || nonce == -1) {
      showCustomError("errorGetNonce".tr);
      return;
    }
    /// use bigger nonce when send multiple messages in a short time
    var realNonce = max(nonce, nonceBoxInstance.get(from).value);
    var value = fil2Atto(_amountCtl.text.trim());
    var msg = TMessage(
        version: 0,
        method: 0,
        nonce: realNonce,
        from: from,
        to: to,
        params: "",
        value: value,
        gasFeeCap: controller.gas.value.feeCap,
        gasLimit: controller.gas.value.gasLimit,
        gasPremium: controller.gas.value.premium);
    String sign = '';
    num signType;
    var cid = await Flotus.messageCid(msg: jsonEncode(msg));
    if (controller.wal.type == '1') {
      signType = SignTypeSecp;
      sign = await Flotus.secpSign(ck: ck, msg: cid);
    } else {
      signType = SignTypeBls;
      sign = await Bls.cksign(num: "$ck $cid");
    }
    var sm = SignedMessage(msg, Signature(signType, sign));
    showCustomLoading('sending'.tr);
    String res = await pushSignedMsg(sm.toLotusSignedMessage());
    dismissAllToast();
    if (res != '') {
      showCustomToast('sended'.tr);
      var cacheGas = CacheGas(
          cid: res,
          feeCap: controller.gas.value.feeCap,
          gasLimit: controller.gas.value.gasLimit,
          premium: controller.gas.value.premium);
      OpenedBox.gasInsance.put('$from\_$realNonce', cacheGas);
      controller.setGas(Gas());
      Hive.box<StoreMessage>(messageBox).put(
          res,
          StoreMessage(
              pending: 1,
              from: from,
              to: to,
              value: value,
              owner: from,
              nonce: realNonce,
              signedCid: res,
              blockTime:
                  (DateTime.now().millisecondsSinceEpoch / 1000).truncate()));
      var oldNonce = nonceBoxInstance.get(from);
      nonceBoxInstance.put(
          from, Nonce(value: realNonce + 1, time: oldNonce.time));
    } else {
      showCustomError('sendFail'.tr);
    }
    if (mounted) {
      Get.back();
    }
  }

  bool checkInputValid() {
    var amount = _amountCtl.text;
    var toAddress = _addressCtl.text;
    var trimAmount = amount.trim();
    var feeCap = controller.gas.value.feeCap;
    var gasLimit = controller.gas.value.gasLimit;
    if (trimAmount == "" || !isDecimal(trimAmount)) {
      showCustomError('enterValidAmount'.tr);
      return false;
    }
    var a = double.parse(trimAmount);
    if (a == 0) {
      showCustomError('enterValidAmount'.tr);
      return false;
    }
    //var b = double.parse(controller.wal.balance);
    var balance = double.parse(fil2Atto(controller.wal.balance));
    var amountAtto = double.parse(fil2Atto(trimAmount));
    var maxFee = double.parse(feeCap) * gasLimit;

    if (balance < amountAtto + maxFee) {
      showCustomError('errorLowBalance'.tr);
      return false;
    }
    var trimAddress = toAddress.trim();
    if (trimAddress == "") {
      showCustomError('enterAddr'.tr);
      return false;
    }
    if (!isValidAddress(trimAddress)) {
      showCustomError('errorAddr'.tr);
      return false;
    }
    if (trimAddress == singleStoreController.wal.addr) {
      showCustomError('errorFromAsTo'.tr);
      return false;
    }

    return true;
  }
  /// get the nonce of the wallet
  void _getNonce() async {
    var wal = singleStoreController.wal;
    var nonce = await getNonce(wal);
    var address = wal.address;
    var now = DateTime.now().millisecondsSinceEpoch;
    if (nonce != -1) {
      this.nonce = nonce;
      if (!nonceBoxInstance.containsKey(address)) {
        nonceBoxInstance.put(address, Nonce(time: now, value: nonce));
      } else {
        Nonce nonceInfo = nonceBoxInstance.get(address);
        var interval = 5 * 60 * 1000;
        if (now - nonceInfo.time > interval) {
          nonceBoxInstance.put(address, Nonce(time: now, value: nonce));
        }
      }
    }
  }

  String get maxFee {
    var feeCap = controller.gas.value.feeCap;
    var gasLimit = controller.gas.value.gasLimit;
    return formatFil(attoFil: (double.parse(feeCap) * gasLimit));
  }

  void checkInputToGetGas() {
    //var trimAmount = _amountCtl.text.trim();
    var trimAddress = _addressCtl.text.trim();
    if (trimAddress != '' && isValidAddress(trimAddress)) {
      getGas();
    }
  }

  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
        .then((scanResult) {
      if (scanResult != '') {
        if (isValidAddress(scanResult)) {
          _addressCtl.text = scanResult;
        } else {
          showCustomError('errorAddr'.tr);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var feeCap = controller.gas.value.feeCap;
    var gasLimit = controller.gas.value.gasLimit;
    var maxFee = formatFil(attoFil: (double.parse(feeCap) * gasLimit));
    return CommonScaffold(
      grey: true,
      title: 'send'.tr,
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
      onPressed: () {
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
                      to: _addressCtl.text,
                      gas: controller.maxFee,
                      value: _amountCtl.text,
                      onConfirm: (String ck) {
                        _pushMsg(ck);
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
                          var wal = singleStoreController.wal;
                          var ck = await getPrivateKey(
                              wal.addrWithNet, pass, wal.skKek);
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
              controller: _addressCtl,
              label: 'to'.tr,
              extra: GestureDetector(
                child: Padding(
                  child: Image(width: 20, image: AssetImage('icons/book.png')),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                ),
                onTap: () {
                  Get.toNamed(addressSelectPage).then((value) {
                    if (value != null) {
                      _addressCtl.text = (value as Wallet).address;
                    }
                  });
                  //Get.toNamed(filGasPage);
                },
              ),
            ),
            Field(
              controller: _amountCtl,
              type: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [PrecisionLimitFormatter(8)],
              label: 'amount'.tr,
              append: Obx(() => CommonText(
                    '${double.parse(controller.wal.balance).toStringAsFixed(6)} FIL',
                    color: CustomColor.grey,
                  )),
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
                        CommonText(
                          maxFee,
                          size: 14,
                          color: Colors.white,
                        ),
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
  final EdgeInsets padding = EdgeInsets.symmetric(horizontal: 12, vertical: 14);
  ConfirmSheet(
      {this.from, this.to, this.gas, this.value, this.onConfirm, this.footer});
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
                      '-$value Fil',
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
                          var wal = singleStoreController.wal;
                          var ck = await getPrivateKey(
                              wal.addrWithNet, pass, wal.skKek);
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
