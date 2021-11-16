// import 'package:fil/index.dart';
import 'dart:math';
import 'package:fil/bloc/gas/gas_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/store/store.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/common/utils.dart';
import 'package:flutter/services.dart';

/// customize gas fee
class ChainGasPage extends StatefulWidget {
  @override
  State createState() => ChainGasPageState();
}

class ChainGasPageState extends State<ChainGasPage> {
  TextEditingController feeCapCtrl = TextEditingController();
  TextEditingController gasLimitCtrl = TextEditingController();
  int index = 0;
  ChainGas chainGas = ChainGas();

  final titles = {
    "errorSetGas":'errorSetGas'.tr,
    "advanced": 'advanced'.tr,
    "sure": 'sure'.tr,
    "fee": 'fee'.tr,
    "feeRate": 'feeRate'.tr,
    "fast": 'fast'.tr,
    "normal": 'normal'.tr,
    "minute": 'minute'.tr,
    "custom":'custom'.tr
  };


  Color getTextColor(bool filter) {
    return filter ? Colors.white : CustomColor.grey;
  }

  bool get isEth => $store.net.addressType == 'eth';

  ChainGas get gas {
    return $store.g.value;
  }

  void onTap(context, int idx, ChainGas gas){
    if(idx==0) {
      BlocProvider.of<GasBloc>(context)..add(ChangeIndex(index: idx, chainGas: gas));
    }else if(idx==1){
      BlocProvider.of<GasBloc>(context)..add(ChangeIndex(index: idx, chainGas: gas.slow));
    } else{ // idx==2
      BlocProvider.of<GasBloc>(context)..add(ChangeIndex(index: idx));
      syncGas(gas, trunc: true);
    }
  }

  void handleSubmit(BuildContext context) {
    final feeCap = feeCapCtrl.text.trim();
    final gasLimit = gasLimitCtrl.text.trim();
    var feeCapNum = double.parse(feeCap);
    if (feeCap == '' || gasLimit == '') {
      showCustomError('errorSetGas'.tr);
      return;
    }
    if (index == 2) {
      BlocProvider.of<GasBloc>(context)..add(
          ChangeIndex(
            chainGas: ChainGas(
            level: 2,
            gasLimit: int.tryParse(gasLimit),
            gasPrice: isEth
                ? (BigInt.from(pow(10, 9) * feeCapNum)).toString()
                : feeCapNum.truncate().toString(),
            gasPremium: isEth
                ? chainGas.gasPremium
                : (feeCapNum - 100).truncate().toString())
         )
      );
    }
    unFocusOf(context);
    Get.back();
  }

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments['gas'] != null) {
      chainGas = Get.arguments['gas'] as ChainGas;
      syncGas(chainGas);
    }
    if ($store.gas.level == 2) {
      syncGas($store.gas);
    }
  }

  void syncGas(ChainGas g, {bool trunc = false}) {
    if (isEth) {
      var price = double.tryParse(g.gasPrice);
      feeCapCtrl.text = price != null
          ? (trunc ? truncate(price / pow(10, 9), size: 5) : (price / pow(10, 9))).toString()
          : g.gasPrice;
    } else {
      feeCapCtrl.text = g.gasPrice;
    }
    gasLimitCtrl.text = g.gasLimit.toString();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).viewInsets.bottom;
    return BlocProvider(
       create: (context) => GasBloc()..add(ChangeIndex(index: $store.gas.level, chainGas: chainGas)),
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
                             Obx(() => CommonText.white($store.gas.maxFee, size: 18))
                           ],
                         ),
                         SizedBox(
                           height: 8,
                         ),
                         // Container(
                         //   alignment: Alignment.bottomRight,
                         //   child: CommonText.white(feePrice, size: 10),
                         // )
                       ],
                     ),
                 ),
                 Container(
                   padding: EdgeInsets.symmetric(vertical: 12),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       CommonText.main('feeRate'.tr),
                       // Image(
                       //   width: 20,
                       //   image: AssetImage('images/que.png'),
                       // )
                     ],
                   ),
                 ),
                 GestureDetector(
                   child: Container(
                     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                     decoration: BoxDecoration(
                         borderRadius: CustomRadius.b8,
                         color: state.index == 0 ? CustomColor.primary : Colors.white),
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 CommonText(
                                   'fast'.tr,
                                   color: getTextColor(state.index == 0),
                                 ),
                                 CommonText(
                                   formatCoin(state.chainGas.gasPrice, size: 5),
                                   size: 10,
                                   color: getTextColor(state.index == 0),
                                 )
                               ],
                             )),
                         CommonText(
                           '<1${'minute'.tr}',
                           color: getTextColor(state.index == 0),
                         )
                       ],
                     ),
                   ),
                   onTap: ()=>{ onTap(ctx, 0, state.chainGas)},
                 ),
                 SizedBox(
                   height: 7,
                 ),
                 Visibility(
                     child: Column(
                       children: [
                         GestureDetector(
                           child: Container(
                             padding:
                             EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                             decoration: BoxDecoration(
                                 borderRadius: CustomRadius.b8,
                                 color:
                                 state.index == 1 ? CustomColor.primary : Colors.white),
                             child: Row(
                               crossAxisAlignment: CrossAxisAlignment.center,
                               children: [
                                 Expanded(
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         CommonText(
                                           'normal'.tr,
                                           color: getTextColor(state.index == 1),
                                         ),
                                         CommonText(
                                           formatCoin(state.chainGas.slow.gasPrice, size: 5),
                                           size: 10,
                                           color: getTextColor(state.index == 1),
                                         ),
                                       ],
                                     )),
                                     CommonText(
                                       '<3${'minute'.tr}',
                                       color: getTextColor(state.index == 1),
                                     )
                                   ],
                                     ),
                          ),
                           onTap: ()=>{onTap(ctx,1, state.chainGas)},
                         ),
                         SizedBox(
                           height: 7,
                         )
                       ],
                     ),
                    visible: !isEth,
                 ),
                 state.index!=2 ?
                     GestureDetector(
                       onTap: () =>{onTap(ctx, 2, state.chainGas)},
                       child: Container(
                         width: double.infinity,
                         decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(8)),
                         padding:
                         EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                         child: CommonText.grey('custom'.tr),
                       ),
                     )
                     : Container(
                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                   decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(8),
                       color: CustomColor.primary),
                   child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         CommonText.white('custom'.tr),
                         Divider(
                           color: Colors.white,
                         ),
                         CommonText.white(isEth ? 'GasPrice' : 'GasFeeCap',
                             size: 10),
                         Field(
                           label: '',
                           controller: feeCapCtrl,
                           type: TextInputType.number,
                           extra: Padding(
                             padding: EdgeInsets.only(right: 12),
                             child: CommonText(isEth ? 'gwei' : 'attoFIL'),
                           ),
                           inputFormatters: [
                             isEth
                                 ? FilteringTextInputFormatter.allow(
                                 RegExp(r"[0-9.]"))
                                 : FilteringTextInputFormatter.digitsOnly
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
                   )
               ],
             ),
           )
         );
       }),
    );
  }
}
