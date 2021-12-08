import 'package:fil/bloc/gas/gas_bloc.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/index.dart';
import 'package:fil/widgets/field.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:fil/common/global.dart';
import 'package:fil/common/formatter.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/index.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/chain/net.dart';
import 'package:flutter/services.dart';
import 'package:fil/init/hive.dart';

class FilTransferNewPage extends StatefulWidget {
  @override
  State createState() => FilTransferNewPageState();
}

class FilTransferNewPageState extends State<FilTransferNewPage> {
  String balance = '0';
  TextEditingController amountCtrl = TextEditingController();
  TextEditingController addressCtrl = TextEditingController();
  int nonce;
  FocusNode focusNode = FocusNode();
  String from = $store.wal.addr;
  String rpc = $store.net.rpc;
  Network net = $store.net;
  ChainGas gas;
  ChainWallet wallet = $store.wal;
  Token token = Global.cacheToken;
  bool loading = false;
  String prePage;
  String rpcType;
  bool isSpeedUp;
  var nonceBoxInstance = OpenedBox.nonceInsance;

  @override
  void initState() {
    super.initState();
    isSpeedUp = false;
    if (Get.arguments != null) {
      if (Get.arguments['to'] != null) {
        addressCtrl.text = Get.arguments['to'];
        // getGas();
      }
      if (Get.arguments['page'] != null) {
        prePage = Get.arguments['page'];
      }

      if (($store.net.chain == 'eth') && ($store.net.net == 'main')) {
        rpcType = 'ethMain';
      } else if ($store.net.chain == 'filecoin') {
        rpcType = 'filecoin';
      } else {
        rpcType = 'ethOthers';
      }

      if (Get.arguments['token'] != null) {
        this.token = Get.arguments['token'];
      }
    }
  }

  @override
  void dispose() {
    $store.setGas(ChainGas());
    amountCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  bool get isToken => token != null;

  String get title => token != null ? token.symbol : $store.net.coin;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => GasBloc()
              ..add(
                UpdateMessListStateEvent($store.net.rpc,$store.net.chain,title)
            )
        ),
      ],
      child: BlocBuilder<GasBloc, GasState>(builder: (ctx, data) {
        return BlocListener<GasBloc, GasState>(
            listener: (context, state) {
              if (state.getGasState == 'success') {
                getGasCallback();
              }
              if(state.getGasState == 'error'){
                if(state.errorMessage.isNotEmpty){
                  showCustomError(state.errorMessage);
                }else{
                  showCustomError('gasFail'.tr);
                }
              }
            },
            child: CommonScaffold(
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
              onPressed: () => nextStep(ctx),
              body: _body(),
            ));
      }),
    );
  }

  Widget _body() {
    return Padding(
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
                  var addr = '';
                  if (value is ContactAddress) {
                    addr = value.address;
                  } else if (value is ChainWallet) {
                    addr = value.addr;
                  }
                  addressCtrl.text = addr;
                });
              },
            ),
          ),
          Field(
            controller: amountCtrl,
            type: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [PrecisionLimitFormatter(18)],
            label: 'amount'.tr,
            append: CommonText(
              token == null
                  ? formatCoin($store.wal.balance) + $store.net.coin
                  : token.formatBalance,
              color: CustomColor.grey,
            ),
          ),
        ],
      ),
    );
  }

  void handleScan() {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Address})
        .then((scanResult) {
      if (scanResult != '') {
        addressCtrl.text = scanResult;
      }
    });
  }

  void getGas(context) {
    var to = addressCtrl.text.trim();
    try {
      if (mounted) {
        BlocProvider.of<GasBloc>(context).add(ResetGetGasStateEvent());
        BlocProvider.of<GasBloc>(context).add(GetGasEvent(
            $store.net.rpc, $store.net.chain, to, isToken, token, rpcType));
      }
    } catch (error) {
      print('error');
    }
  }

  void getGasCallback() {
    try {
      if (isSpeedUp) {
        increaseGas();
      }
      var toAddress = addressCtrl.text.trim();
      var amount = amountCtrl.text.trim();
      bool valid = checkGas();
      if (valid) {
        Get.toNamed(transferConfrimPage, arguments: {
          "to": toAddress,
          "amount": amount,
          "prePage": prePage,
          "isSpeedUp": isSpeedUp
        });
      }
    } catch (error) {
      print('error');
    }
  }

  nextStep(context) async {
    try {
      bool valid = await checkInputValid();
      if (valid) {
        var amount = amountCtrl.text.trim();
        var toAddress = addressCtrl.text.trim();
        List<CacheMessage> pendingList = OpenedBox.mesInstance.values
            .where(
                (mes) => mes.pending == 1 && mes.from == from && mes.rpc == rpc)
            .toList();
        bool showSpeed = pendingList.isNotEmpty;

        if (showSpeed) {
          showCustomModalBottomSheet(
              shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
              context: context,
              builder: (BuildContext ctx) {
                return _speedUpSheet(toAddress, amount, context);
              });
        } else {
          getGas(context);
        }
      }
    } catch (error) {
      print('error');
    }
  }

  bool checkGas() {
    var amount = amountCtrl.text.trim();
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

  Future<bool> checkInputValid() async {
    try {
      var amount = amountCtrl.text.trim();
      var toAddress = addressCtrl.text.trim().toLowerCase();
      if (toAddress == "") {
        showCustomError('enterAddr'.tr);
        return false;
      }
      bool valid = await isValidChainAddress(toAddress, net);
      if (!valid) {
        showCustomError('errorAddr'.tr);
        return false;
      }
      if (toAddress == $store.wal.addr) {
        showCustomError('errorFromAsTo'.tr);
        return false;
      }
      if (amount == "" || !isDecimal(amount)) {
        showCustomError('enterValidAmount'.tr);
        return false;
      }
      var _amount = double.parse(amount);
      if (_amount == 0) {
        showCustomError('enterValidAmount'.tr);
        return false;
      }

      var bigIntBalance =
          BigInt.tryParse(isToken ? token.balance : $store.wal.balance);
      var bigIntAmount = BigInt.from(
          (double.tryParse(amount) * pow(10, isToken ? token.precision : 18)));

      if (bigIntAmount > bigIntBalance) {
        showCustomError('errorLowBalance'.tr);
        return false;
      }

      return true;
    } catch (error) {
      print('err');
      return false;
    }
  }

  void skipConfirmMessages(context,bool) {
    isSpeedUp = bool;
    getGas(context);
  }

  void increaseGas() {
    try {
      var cacheGas = $store.gas;
      var realMaxFeePerGas = $store.gas.maxFeePerGas;
      var realGasFeeCap = $store.gas.gasFeeCap;
      var realGasPrice = $store.gas.gasPrice;

      if (($store.net.chain == 'eth') && ($store.net.net == 'main')) {
        var increaseMaxFeePerGas =
            (int.parse(cacheGas.maxFeePerGas) * Config.increaseGasCoefficient)
                .truncate();
        realMaxFeePerGas =
            (max(int.parse(realMaxFeePerGas), increaseMaxFeePerGas)).toString();
      } else if ($store.net.chain == 'filecoin') {
        var increaseGasFeeCap =
            (int.parse(cacheGas.gasFeeCap) * Config.increaseGasCoefficient)
                .truncate();
        realGasFeeCap =
            (max(int.parse(realGasFeeCap), increaseGasFeeCap)).toString();
      } else {
        var increaseGasPrice =
            (int.parse(cacheGas.gasPrice) * Config.increaseGasCoefficient)
                .truncate();
        realGasPrice =
            (max(int.parse(realGasPrice), increaseGasPrice)).toString();
      }

      var _gas = {
        "gasLimit": $store.gas.gasLimit,
        "gasPremium": $store.gas.gasPremium,
        "gasPrice": realGasPrice,
        "rpcType": $store.gas.rpcType,
        "gasFeeCap": realGasFeeCap,
        "maxPriorityFee": $store.gas.maxPriorityFee,
        "maxFeePerGas": realMaxFeePerGas
      };
      ChainGas transferGas = ChainGas.fromJson(_gas);
      $store.setGas(transferGas);
      print('success');
    } catch (error) {
      print('error');
    }
  }

  Widget _speedUpSheet(toAddress, amount, context) {
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
                TapItemCard(
                  items: [
                    CardItem(
                      label: 'speedup'.tr,
                      onTap: () => skipConfirmMessages(context,true),
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                TapItemCard(
                  items: [
                    CardItem(
                      label: 'continueNew'.tr,
                      onTap: () => skipConfirmMessages(context,false),
                    )
                  ],
                ),
              ],
            ))
      ],
    );
  }
}
