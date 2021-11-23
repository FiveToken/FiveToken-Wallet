import 'package:fil/bloc/mne/mne_bloc.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/pages/wallet/mne.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/common/utils.dart';

class WalletPrivatekeyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletPrivatekeyPageState();
  }
}

class WalletPrivatekeyPageState extends State<WalletPrivatekeyPage> {
  String private = Get.arguments['private'] as String;
  ChainWallet wallet = Get.arguments['wallet'] as ChainWallet;

  void onTap(context, int idx){
    BlocProvider.of<MneBloc>(context).add(SetMneEvent(index:idx));
  }

  void onView(context){
    BlocProvider.of<MneBloc>(context).add(SetMneEvent(showCode: true));
  }


  @override
  Widget build(BuildContext context) {
    var ck = wallet.addressType == 'eth'
        ? private
        : base64ToHex(private, wallet.address[1]);
    return BlocProvider(
        create: (context) => MneBloc()..add(SetMneEvent()),
        child: BlocBuilder<MneBloc, MneState>(builder: (ctx, state){
          return CommonScaffold(
            title: 'exportPk'.tr,
            grey: true,
            footerText: 'copy'.tr,
            onPressed: () {
              copyText(ck);
              showCustomToast('copySucc'.tr);
            },
            body: Column(
              children: [
                KeyString(
                  data: ck,
                )
                // Row(
                //   children: [
                //     Expanded(
                //         child: TabItem(
                //             active: state.index == 0,
                //             label: 'pk'.tr,
                //             onTap: ()=>{onTap(ctx, 0)}
                //         )),
                //     Expanded(
                //         child: TabItem(
                //           active: state.index == 1,
                //           label: 'code'.tr,
                //           onTap: ()=>{onTap(ctx, 1)},
                //         )),
                //   ],
                // ),
                // state.index == 0
                //     ? KeyString(
                //   data: ck,
                // )
                //     : KeyCode(
                //   data: ck,
                //   showCode:state.showCode,
                //   onView: ()=>{onView(ctx)},
                // )
              ],
            ),
          );
        }),
    );
  }
}
