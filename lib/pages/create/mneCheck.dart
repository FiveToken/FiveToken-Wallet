import 'package:fil/bloc/create/create_bloc.dart';
import 'package:fil/common/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/toast.dart';
import './mneCreate.dart';

class MneCheckPage extends StatefulWidget {
  @override
  State createState() => MneCheckPageState();
}

class MneCheckPageState extends State<MneCheckPage> {
  List<String> unSelectedList = [];
  List<String> selectedList = [];
  final String mne = Get.arguments['mne'] as String;
  @override
  void initState() {
    super.initState();
    var list = mne.split(' ');
    list.shuffle();
    unSelectedList = list;
  }

  void handleSelect(BuildContext context, state,  num index) {
    BlocProvider.of<CreateBloc>(context).add(UpdateEvent(type: index));
  }

  void handleRemove(BuildContext context,state,  num index) {
    BlocProvider.of<CreateBloc>(context).add(DeleteEvent(type: index));
  }

  String get mneCk {
    return genCKBase64(mne);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => CreateBloc()..add(SetCreateEvent(unSelectedList: unSelectedList)),
        child: BlocBuilder<CreateBloc, CreateState>(builder: (ctx, state){
          return CommonScaffold(
            grey: true,
            onPressed: () {
              var str = state.selectedList.join(' ');
              if (str != mne || state.selectedList.length < 12) {
                showCustomError('wrongMne'.tr);
                return;
              }
              Get.toNamed(passwordSetPage,
                  arguments: {'type': 0, 'mne': mne, 'label': DefaultWalletName});
            },
            footerText: 'next'.tr,
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          'checkMne'.tr,
                          size: 14,
                          weight: FontWeight.w500,
                        ),
                        CommonText(
                          'clickMne'.tr,
                          size: 14,
                          color: Color(0xffB4B5B7),
                        ),
                      ],
                    ),
                    width: double.infinity,
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 200),
                      child: GridView.count(
                        padding: EdgeInsets.all(10),
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        childAspectRatio: 2.1,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        children: List.generate(state.selectedList.length, (index) {
                          return MneItem(
                            remove: true,
                            label: state.selectedList[index],
                            onTap: ()=> handleRemove(ctx, state, index),
                          );
                        }),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GridView.count(
                    crossAxisCount: 3,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    childAspectRatio: 2.1,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    children: List.generate(state.unSelectedList.length, (index) {
                      return MneItem(
                        label: state.unSelectedList[index],
                        bg: CustomColor.primary,
                        onTap: ()=> handleSelect(ctx,state,index),
                      );
                    }),
                  )
                ],
              ),
              padding: EdgeInsets.fromLTRB(12, 20, 12, 100),
            )
          );
        },
     )
    );
  }
}
