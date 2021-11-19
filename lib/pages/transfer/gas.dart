import 'dart:math';
import 'package:fil/bloc/gas/gas_bloc.dart';
import 'package:fil/chain-new/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/store/store.dart';
import 'package:fil/models-new/chain_gas.dart';
import 'package:fil/common/utils.dart';
import 'package:flutter/services.dart';

/// customize gas fee
class ChainGasPage extends StatefulWidget {
  @override
  State createState() => ChainGasPageState();
}

class ChainGasPageState extends State<ChainGasPage> {
  TextEditingController maxPriorityFeeCtrl = TextEditingController();
  TextEditingController maxFeePerGasCtrl = TextEditingController();
  TextEditingController gasFeeCapCtrl = TextEditingController();
  TextEditingController gasPriceCtrl = TextEditingController();
  TextEditingController gasPremiumCtrl = TextEditingController();
  TextEditingController gasLimitCtrl = TextEditingController();

  String rpcType = '';

  ChainGas storeGas = $store.gas;

  @override
  void initState() {
    super.initState();

    if(($store.net.chain == 'eth') && ($store.net.net == 'main')){
      rpcType = 'ethMain';
    }else if( $store.net.chain == 'filecoin'){
      rpcType = 'filecoin';
    }else{
      rpcType = 'ethOthers';
    }

    initGas();
  }


  void handleSubmit(BuildContext context) {
    // final feeCap = feeCapCtrl.text.trim();
    // final gasLimit = gasLimitCtrl.text.trim();
    // var feeCapNum = double.parse(feeCap);
    // if (feeCap == '' || gasLimit == '') {
    //   showCustomError('errorSetGas'.tr);
    //   return;
    // }
    // unFocusOf(context);
    // Get.back();
  }

  void initGas() {
    maxPriorityFeeCtrl.text = storeGas.maxPriorityFee;
    maxFeePerGasCtrl.text = storeGas.maxFeePerGas;
    gasFeeCapCtrl.text = storeGas.gasFeeCap;
    gasPriceCtrl.text = storeGas.gasPrice;
    gasPremiumCtrl.text = storeGas.gasPremium;
    gasLimitCtrl.text = storeGas.gasLimit.toString();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).viewInsets.bottom;
    return BlocProvider(
       create: (context) => GasBloc(),
       child: BlocBuilder<GasBloc, GasState>(builder: (ctx, state){
         return CommonScaffold(
           title: 'advanced'.tr,
           footerText: 'sure'.tr,
           grey: true,
           onPressed: () {
             handleSubmit(context);
           },
           body: SingleChildScrollView(
             padding: EdgeInsets.fromLTRB(12, 20, 12, h + 100),
             child: Column(
               children: [
                 Container(
                     padding: EdgeInsets.fromLTRB(12, 16, 12, 10),
                     decoration: BoxDecoration(
                         borderRadius: CustomRadius.b8,
                         color: Color(0xff5C8BCB)
                     ),
                     child: Column(
                       children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             CommonText.white('fee'.tr),
                             Obx(() => CommonText.white($store.gas.handlingFee + $store.net.coin, size: 18))
                           ],
                         ),
                         SizedBox(
                           height: 8,
                         ),
                       ],
                     ),
                 ),
                 Container(
                   padding: EdgeInsets.symmetric(vertical: 12),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       CommonText.main('feeRate'.tr),
                     ],
                   ),
                 ),
                 SizedBox(
                   height: 7,
                 ),
                 _getGasWidget()
               ],
             ),
           )
         );
       }),
    );
  }

  Widget _getGasWidget(){
    return  rpcType == 'ethMain' ?
    _ethMainGas():
    (
        rpcType == 'filecoin' ?
        _fileCoinGas():
        _ethOthersGas()
    );
  }
  Widget _fileCoinGas(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: CustomColor.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText.white('GasFeeCap',size: 10),
          Field(
            label: '',
            controller: gasFeeCapCtrl,
            type: TextInputType.number,
            extra: Padding(
              padding: EdgeInsets.only(right: 12),
              child: CommonText('attoFIL'),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
          CommonText.white('GasPremium', size: 10),
          Field(
            label: '',
            controller: gasPremiumCtrl,
            type: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
          CommonText.white('GasLimit', size: 10),
          Field(
            label: '',
            controller: gasLimitCtrl,
            type: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
          )
        ],
      ),
    );
  }

  Widget _ethMainGas(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: CustomColor.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText.white('Max priority fee(Gwei)',
              size: 10),
          Field(
            label: '',
            controller: maxPriorityFeeCtrl,
            type: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[0-9.]"))
            ],
          ),
          SizedBox(
            height: 10,
          ),
          CommonText.white('Max fee(Gwei)', size: 10),
          Field(
            label: '',
            controller: maxFeePerGasCtrl,
            type: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
          ),
          SizedBox(
            height: 10,
          ),
          CommonText.white('GasLimit', size: 10),
          Field(
            label: '',
            controller: gasLimitCtrl,
            type: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
          )
        ],
      ),
    );
  }

  Widget _ethOthersGas(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: CustomColor.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText.white('GasPrice', size: 10),
          Field(
            label: '',
            controller: gasPriceCtrl,
            type: TextInputType.number,
            extra: Padding(
              padding: EdgeInsets.only(right: 12),
              child: CommonText('gwei'),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[0-9.]"))
            ],
          ),
          CommonText.white('GasLimit', size: 10),
          Field(
            label: '',
            controller: gasLimitCtrl,
            type: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
          )
        ],
      ),
    );
  }
}
