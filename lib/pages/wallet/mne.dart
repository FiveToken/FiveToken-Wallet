// import 'package:fil/index.dart';
import 'package:fil/bloc/mne/mne_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/index.dart';
import 'package:fil/pages/create/mneCreate.dart';

class WalletMnePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletMnePageState();
  }
}

class WalletMnePageState extends State<WalletMnePage> {

  void onTap(context, int idx){
    BlocProvider.of<MneBloc>(context).add(SetMneEvent(index:idx));
  }

  void onView(context){
    BlocProvider.of<MneBloc>(context).add(SetMneEvent(showCode: true));
  }

  @override
  Widget build(BuildContext context) {
    var mne = Get.arguments['mne'] as String;
    return BlocProvider(
        create: (context) => MneBloc()..add(SetMneEvent()),
        child: BlocBuilder<MneBloc, MneState>(builder: (ctx,state){
          return CommonScaffold(
              title: 'exportMne'.tr,
              grey: true,
              onPressed: () {
                copyText(mne);
                showCustomToast('copySucc'.tr);
              },
              footerText: 'copy'.tr,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: TabItem(
                              active: state.index == 0,
                              label: 'mne'.tr,
                              onTap: ()=>{ onTap(ctx, 0)},
                            )),
                        Expanded(
                            child: TabItem(
                              active: state.index == 1,
                              label: 'code'.tr,
                              onTap: ()=>{onTap(ctx,1)},
                            )),
                      ],
                    ),
                    state.index == 0
                        ? KeyString(
                      data: mne,
                      isMne: true,
                    )
                        : KeyCode(
                      data: mne,
                      showCode: state.showCode,
                      onView: ()=>{onView(ctx)},
                    )
                  ],
                ),
              ),
            );
        }),
    );
  }
}

class TabItem extends StatelessWidget {
  final bool active;
  final String label;
  final Noop onTap;
  TabItem({this.active, this.label, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: active ? CustomColor.primary : Colors.transparent,
                    width: 2))),
        alignment: Alignment.center,
        child: CommonText(
          label,
          size: 14,
          weight: FontWeight.w500,
          color: active ? CustomColor.primary : CustomColor.grey,
        ),
      ),
      onTap: onTap,
    );
  }
}

class KeyString extends StatelessWidget {
  final String data;
  final bool isMne;
  KeyString({this.data, this.isMne = false});
  @override
  Widget build(BuildContext context) {
    var selectedList = data.split(' ');
    return Padding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            'notUseNet'.tr,
            color: CustomColor.primary,
            size: 14,
          ),
          CommonText(
            'tip4'.tr,
            color: CustomColor.grey,
            size: 14,
          ),
          CommonText(
            'offline'.tr,
            color: CustomColor.primary,
            size: 14,
          ),
          CommonText(
            'tip5'.tr,
            color: CustomColor.grey,
            size: 14,
          ),
          SizedBox(
            height: 27,
          ),
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: Colors.white),
              child: !isMne
                  ? Container(
                      child: CommonText(data),
                      padding: EdgeInsets.all(15),
                    )
                  : ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 200),
                      child: GridView.count(
                        padding: EdgeInsets.all(10),
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        childAspectRatio: 2.1,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        children: List.generate(selectedList.length, (index) {
                          return MneItem(
                            label: selectedList[index],
                            onTap: () {},
                          );
                        }),
                      ),
                    ),
            ),
            onTap: () {
              copyText(data);
              showCustomToast('copySucc'.tr);
            },
          )
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

class KeyCode extends StatelessWidget {
  final bool showCode;
  final Noop onView;
  final String data;
  KeyCode({this.showCode, this.onView, this.data});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                'onlyScan'.tr,
                color: CustomColor.primary,
                size: 14,
              ),
              CommonText(
                'tip6'.tr,
                color: CustomColor.grey,
                size: 14,
              ),
              CommonText(
                'useSafe'.tr,
                color: CustomColor.primary,
                size: 14,
              ),
              CommonText(
                'tip7'.tr,
                color: CustomColor.grey,
                size: 14,
              ),
            ],
          ),
        ),
        Container(
          height: 244,
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(65, 28, 65, 0),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: !showCode
              ? GestureDetector(
                  onTap: onView,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 56,
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          color: CustomColor.bgGrey,
                        ),
                        padding: EdgeInsets.all(20),
                        child: Image(image: AssetImage('icons/close-eye.png')),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      CommonText(
                        'noPerson'.tr,
                        color: CustomColor.grey,
                        weight: FontWeight.w500,
                        size: 14,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      CommonText(
                        'view'.tr,
                        weight: FontWeight.w500,
                        size: 14,
                        color: CustomColor.primary,
                      )
                    ],
                  ),
                )
              : Container(
                  height: 244,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: QrImage(
                    data: data,
                    size: 188,
                    backgroundColor: Colors.white,
                    version: QrVersions.auto,
                  )),
        )
      ],
    );
  }
}
