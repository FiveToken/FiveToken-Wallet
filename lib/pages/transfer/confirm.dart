import 'dart:math';
import 'package:decimal/decimal.dart' show Decimal;
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/bloc/transfer/transfer_bloc.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/cacheMessage.dart' show CacheMessage;
import 'package:fil/models/nonce.dart' show Nonce;
import 'package:fil/store/store.dart';
import 'package:fil/widgets/dialog.dart' show showPassDialog;
import 'package:fil/widgets/style.dart' show CustomColor, CustomRadius;
import 'package:fil/widgets/text.dart' show CommonText;
import 'package:fil/widgets/toast.dart' show showCustomError, showCustomToast;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:fil/routes/path.dart';
import 'package:oktoast/oktoast.dart';
import 'package:fil/utils/string_extension.dart';
import 'package:fil/utils/decimal_extension.dart';

class TransferConfirmPage extends StatefulWidget {
  @override
  State createState() => TransferConfirmPageState();
}

class TransferConfirmPageState extends State<TransferConfirmPage> {
  var nonceBoxInstance = OpenedBox.nonceInsance;
  Token token;
  bool isToken = false;
  String symbol = "";

  final EdgeInsets padding = EdgeInsets.symmetric(horizontal: 12, vertical: 14);
  ChainGas gas;
  String from = $store.wal.addr;
  String rpc = $store.net.rpc;
  String chainType = $store.net.chain;
  String to = '';
  String amount = '';
  String prePage;
  bool isSpeedUp = false;

  // Get the message of current account pending message
  List<CacheMessage> get pendingList {
    return OpenedBox.mesInstance.values
        .where((mes) => mes.pending == 1 && mes.from == from && mes.rpc == rpc)
        .toList();
  }

  bool get showSpeed {
    return pendingList.isNotEmpty;
  }

  // Service Charge
  String get handlingFee {
    var fee = $store.gas.handlingFee;
    var unit = BigInt.from(pow(10, 18));
    var res = (BigInt.parse(fee) / unit).toStringAsFixed(8);
    return res;
  }

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['to'] != null) {
        to = Get.arguments['to'] as String;
      }
      if (Get.arguments['amount'] != null) {
        amount = Get.arguments['amount'] as String;
      }
      if (Get.arguments['prePage'] != null) {
        prePage = Get.arguments['prePage'] as String;
      }
      if (Get.arguments['isSpeedUp'] != null) {
        var lastMessage = pendingList.last;
        isSpeedUp = Get.arguments['isSpeedUp'] as bool;
        symbol = lastMessage.token != null ? lastMessage.token.symbol:lastMessage.symbol;
        isToken = lastMessage.token != null ? true : false;
        token = lastMessage.token != null ? lastMessage.token : Global.cacheToken;
      }else{
        token = Global.cacheToken;
        symbol =  token != null ? token.symbol : $store.net.coin;
        isToken = token != null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (BuildContext context) => TransferBloc()..add(GetNonceEvent(rpc, chainType, from)),
        ),
      ],
      child:BlocBuilder<TransferBloc, TransferState>(
          builder: (BuildContext context, data) {
          return BlocListener<TransferBloc, TransferState>(
            listener: (context, state) {
              if (state.messageState == 'success') {
                showCustomToast('sended'.tr);
                if(isSpeedUp){
                  var lastMessage = pendingList.last;
                  pushMsgCallBack(lastMessage.nonce.toInt(), state.response.cid);
                }else{
                  pushMsgCallBack(state.nonce, state.response.cid);
                }

              }
              if (state.messageState == 'error') {
                try{
                  String message = state.response.message;
                  if(message.isNotEmpty){
                    showCustomError(message);
                  }else{
                    showCustomError('sendFail'.tr);
                  }

                  if(isSpeedUp){
                    var lastMessage = pendingList.last;
                    if(lastMessage.token == null){
                      Global.cacheToken = null;
                    }
                    if(lastMessage.token != null){
                      Global.cacheToken = lastMessage.token;
                    }
                    if(prePage == walletMainPage){
                      Get.offAndToNamed(walletMainPage, arguments: {"symbol": symbol});
                    }else{
                      Get.offAndToNamed(mainPage);
                    }
                  }
                }catch(error){
                  showCustomError('sendFail'.tr);
                }
              }
            },
            child: BlocBuilder<MainBloc, MainState>(
              builder: (BuildContext context, mainState) {
                return CommonScaffold(
                  grey: true,
                  title: 'send'.tr + symbol,
                  footerText: 'next'.tr,
                  onPressed: () {
                    showPassDialog(context, (String pass) async {
                      var wal = $store.wal;
                      var ck = await wal.getPrivateKey(pass);
                      pushMessage(data.nonce, ck, context);
                    });
                  },
                  body: _body(mainState)
                );
              }
            )
          );
        }
      )
    );
  }

  Widget _body(state) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: padding,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText.grey(dotString(str: $store.wal.addr)),
                Image(width: 18, image: AssetImage('icons/right-bg.png')),
                CommonText.grey(dotString(str: to)),
              ],
            ),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: CustomRadius.b8),
          ),
          Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText.main('amount'.tr),
                Visibility(
                  child: CommonText(
                    getAmountUsdPrice(state.usd),
                    color: CustomColor.grey,
                  ),
                  visible: state.usd as double> 0,
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: padding,
              margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
              child: CommonText.grey(amount + ' ' + symbol),
              decoration: BoxDecoration(
                  color: Color(0xffe6e6e6), borderRadius: CustomRadius.b8),
            ),
            Obx(() => SetGas(
                maxFee: handlingFee, gas: gas, usdPrice: state.usd as num)),
            SizedBox(
              height: 20,
            ),
            Visibility(
                child: Column(
                  children: [
                    Obx(() =>
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonText.main('totalPay'.tr),
                            CommonText(
                              getTotalUsd(state.usd),
                              color: CustomColor.grey,
                            )
                          ],
                        )
                    ),
                    Container(
                      width: double.infinity,
                      padding: padding,
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => CommonText(getTotal())),
                          CommonText.grey("Amount + Gas Fee")
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xffe6e6e6), borderRadius: CustomRadius.b8),
                    ),
                  ],
                ),
                visible: !isToken,
            ),

          ])
        ]));
  }
  /*
  * get amount usd price
  * @param {string} usd: The current currency corresponds to the US dollar price
  * */
  String getAmountUsdPrice(usd) {
    if (isToken) {
      return '';
    } else {
      var _amount = Decimal.parse(amount) * Decimal.parse(usd.toString());
      var usdPrice = _amount.toStringAsFixed(8);
      String unit = '\$ ';
      return unit + usdPrice;
    }
  }

  /*
  * get total usd price
  * @param {string} usd: The current currency corresponds to the US dollar price
  */
  String  getTotalUsd(usd) {
    var total = Decimal.parse(amount) + Decimal.parse(handlingFee);
    var totalUsd = Decimal.parse(total.toString()) * Decimal.parse(usd.toString());
    String unit = '\$ ';
    var _decimal = totalUsd.toString().toDecimal;
    var res = _decimal.fmtDown(8);
    if(isToken){
      return '';
    }else{
      return unit + res;
    }

  }

  // get total price
  String getTotal() {
    try {
      if(isToken){
        return amount + ' ' + symbol + ' + ' + handlingFee + ' ' + $store.net.coin;
      }else{
        var total = Decimal.parse(amount) + Decimal.parse(handlingFee);
        return total.toStringAsFixed(8) + $store.net.coin;
      }

    } catch (error) {
      return '';
    }
  }

  // Handling Fee Check
  bool checkGas() {
    var handlingFee = BigInt.parse($store.gas.handlingFee);
    var bigIntBalance =
        BigInt.tryParse(isToken ? token.balance : $store.wal.balance);
    var bigIntAmount = BigInt.from(
        (double.tryParse(amount) * pow(10, isToken ? token.precision : 18)));

    if (isToken) {
      var mainBigIntBalance = BigInt.parse($store.wal.balance);
      if ((bigIntAmount > bigIntBalance) || (handlingFee > mainBigIntBalance)) {
        showCustomError('errorLowBalance'.tr);
        return false;
      }
    } else {
      if (bigIntBalance < handlingFee + bigIntAmount) {
        showCustomError('errorLowBalance'.tr);
        return false;
      }
    }
    return true;
  }
  /*
  * send transaction
  *  @param {num} nonce: the nonce of the current account
  *  @param {string} ck: private key
  *  @param {context} context: context
  * */
  void pushMessage(int nonce, String ck, BuildContext context) async {
    if (!Global.online) {
      showCustomError('errorNet'.tr);
      return;
    }
    try {
      if (isSpeedUp) {
        bool valid = checkGas();
        if (valid) {
          pendingList.sort((a, b) {
            if (a.nonce != null && b.nonce != null) {
              return b.nonce.compareTo(a.nonce);
            } else {
              return -1;
            }
          });
          var lastMessage = pendingList.last;
          bool _isToken = lastMessage.token != null;
          BlocProvider.of<TransferBloc>(context).add(ResetSendMessageEvent());
          BlocProvider.of<TransferBloc>(context).add(SendTransactionEvent(
              rpc,
              chainType,
              from,
              lastMessage.to,
              lastMessage.value,
              ck,
              lastMessage.nonce.toInt(),
              $store.gas,
              _isToken,
              lastMessage.token));
        }
      } else {
        bool valid = checkGas();
        if (valid) {
          var value = getChainValue(amount, precision: token?.precision ?? 18);


          BlocProvider.of<TransferBloc>(context).add(ResetSendMessageEvent());
          BlocProvider.of<TransferBloc>(context).add(SendTransactionEvent(
              rpc,
              chainType,
              from,
              to,
              value,
              ck,
              nonce,
              $store.gas,
              isToken,
              token));
        }
      }
    } catch (e) {
      dismissAllToast();
      showCustomError('sendFail'.tr);
    }
  }
  /*
  * Send transaction callback function
  * @param {num} nonce: the nonce of the current account
  * @param {string} hash: The hash value of the transaction
  * */
  void pushMsgCallBack(int nonce, String hash) {
    try {
      var value = getChainValue(amount, precision: token?.precision ?? 18);
      var nonceKey = '$from\_${rpc}';
      var gasKey = '$from\_$nonce\_${rpc}';
      var _gas = {
        "gasLimit": $store.gas.gasLimit,
        "gasPremium": $store.gas.gasPremium,
        "gasPrice": $store.gas.gasPrice,
        "rpcType": $store.gas.rpcType,
        "gasFeeCap": $store.gas.gasFeeCap,
        "maxPriorityFee": $store.gas.maxPriorityFee,
        "maxFeePerGas": $store.gas.maxFeePerGas,
        "baseFeePerGas":$store.gas.baseFeePerGas,
        "baseMaxPriorityFee":$store.gas.baseMaxPriorityFee,
      };
      ChainGas transferGas = ChainGas.fromJson(_gas);
      $store.setGas(transferGas);
      OpenedBox.gasInsance.put(
          gasKey,
          ChainGas(
              gasLimit: $store.gas.gasLimit,
              gasPremium: $store.gas.gasPremium,
              gasPrice: $store.gas.gasPrice,
              rpcType: $store.gas.rpcType,
              gasFeeCap: $store.gas.gasFeeCap,
              maxPriorityFee: $store.gas.maxPriorityFee,
              maxFeePerGas: $store.gas.maxFeePerGas
          )
      );
      OpenedBox.mesInstance.put(
          hash,
          CacheMessage(
              pending: 1,
              from: from,
              to: to,
              value: value,
              owner: from,
              nonce: nonce,
              hash: hash,
              rpc: rpc,
              token: token,
              gas: $store.gas,
              exitCode: -1,
              fee: $store.gas.handlingFee ?? '0',
              symbol: symbol,
              blockTime:
                  (DateTime.now().millisecondsSinceEpoch / 1000).truncate()));

      // var storeNonce = nonceBoxInstance.get(nonceKey);
      var now = getSecondSinceEpoch();
      nonceBoxInstance.put(
          nonceKey, Nonce(value: nonce + 1, time: now)
      );

      if (mounted) {
        goBack();
      }
    } catch (error) {
      throw(error);
    }
  }

  /*
  * Return to previous page
  * */
  void goBack() {
    var lastMessage = pendingList.last;
    if(isSpeedUp && lastMessage.token == null){
      Global.cacheToken = null;
    }
    if(isSpeedUp && lastMessage.token != null){
      Global.cacheToken = lastMessage.token;
    }
    Get.offAndToNamed(walletMainPage, arguments: {"symbol": symbol});
  }
}


class SetGas extends StatelessWidget {
  final String maxFee;
  final ChainGas gas;
  final num usdPrice;
  SetGas({@required this.maxFee, this.gas, this.usdPrice});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText.main('fee'.tr),
                CommonText(
                  getFeeUsdPrice(),
                  color: CustomColor.grey,
                )
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            decoration: BoxDecoration(
                color: Color(0xff5C8BCB), borderRadius: CustomRadius.b8),
            child: Row(
              children: [
                CommonText(
                  maxFee + ' ' + $store.net.coin,
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
    );
  }

  String getFeeUsdPrice() {
    try {
      var usdFee = Decimal.parse(maxFee) * Decimal.parse(usdPrice.toString());
      var res = usdFee.toStringAsFixed(8);
      String unit = '\$ ';
      return unit + res;
    } catch (error) {
      return '';
    }
  }
}
