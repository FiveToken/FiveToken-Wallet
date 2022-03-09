import 'package:fil/bloc/mne/mne_bloc.dart';
import 'package:fil/chain/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenshot_events/flutter_screenshot_events.dart';
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
// Page of privateKey wallet
class WalletPrivatekeyPageState extends State<WalletPrivatekeyPage> {
  String private = Get.arguments['private'] as String;
  ChainWallet wallet = Get.arguments['wallet'] as ChainWallet;
  String _message = "";
  void onTap(BuildContext context, int idx){
    BlocProvider.of<MneBloc>(context).add(SetMneEvent(index:idx));
  }

  void onView(BuildContext context){
    BlocProvider.of<MneBloc>(context).add(SetMneEvent(showCode: true));
  }

  void dispose() {
    super.dispose();
    FlutterScreenshotEvents.disableScreenshots(false);
  }

  @override
  void initState() {
    super.initState();
    if(mounted){
      FlutterScreenshotEvents.disableScreenshots(true);
      FlutterScreenshotEvents.statusStream?.listen((event) {
        setState(() {
          _message = event.toString();
          showCustomToast(_message);
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    var ck = wallet.addressType == 'eth'
        ?  '0x$private'
        : base64ToHex(private, wallet.address[1]);
    return BlocProvider(
        create: (context) => MneBloc()..add(SetMneEvent()),
        child: BlocBuilder<MneBloc, MneState>(builder: (ctx, state){
          return CommonScaffold(
            title: 'exportPk'.tr,
            grey: true,
            footerText: 'cancel'.tr,
            onPressed: () {
              Get.back();
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
