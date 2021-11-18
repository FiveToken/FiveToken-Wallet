import 'package:fil/bloc/transfer/transfer_bloc.dart';
import 'package:fil/bloc/wallet/wallet_bloc.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/index.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:fil/routes/path.dart';

import 'package:fil/models-new/chain_gas.dart';

class TransferConfirmPage extends StatefulWidget {
  @override
  State createState() => TransferConfirmPageState();
}

class TransferConfirmPageState extends State<TransferConfirmPage> {
  Token token = Global.cacheToken;
  bool get isToken => token != null;
  String get title => token != null ? token.symbol : $store.net.coin;
  final EdgeInsets padding = EdgeInsets.symmetric(horizontal: 12, vertical: 14);
  ChainGas gas;
  String to = '';
  String amount = '';


  @override
  void initState(){
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['to'] != null) {
        to = Get.arguments['to'];
      }
      if (Get.arguments['amount'] != null) {
        amount = Get.arguments['amount'];
      }
    }
  }
  @override
  Widget build(BuildContext context){
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => WalletBloc()
          ),
          BlocProvider(
              create: (context) => TransferBloc()
          )
        ],
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state){
            return BlocBuilder<TransferBloc,TransferState>(
                builder:(ctx,data){
                  return CommonScaffold(
                      grey: true,
                      title: 'send'.tr + title,
                      footerText: 'next'.tr,
                      onPressed:(){},
                      body:_body()
                  );
                }
            );
          },
        )
    );
  }
  Widget _body(){
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Container(
                padding: padding,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                child:Row(
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
              Column(
                  children:[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText.grey('amount'.tr),
                        CommonText(
                          token == null
                              ? formatCoin($store.wal.balance)
                              : token.formatBalance,
                          color: CustomColor.grey,
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: padding,
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                      child: CommonText.grey(amount+$store.net.coin),
                      decoration: BoxDecoration(
                          color: Color(0xffe6e6e6), borderRadius: CustomRadius.b8
                      ),
                    ),
                    Obx(() => SetGas(
                          maxFee: $store.gas.handlingFee + $store.net.coin,
                          gas: gas,
                        )),
                  ]
              )
            ]
        )
    );
  }
}



class SetGas extends StatelessWidget {
  final String maxFee;
  final ChainGas gas;
  SetGas({@required this.maxFee, this.gas});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                color: Color(0xff5C8BCB), borderRadius: CustomRadius.b8),
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
                TapItemCard(
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
                TapItemCard(
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
