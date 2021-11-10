import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/chain/net.dart';
// import 'package:fil/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/layout.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/card.dart';
import 'package:get/get.dart';

class AddressBookNetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddressBookNetState();
  }
}

class AddressBookNetState extends State<AddressBookNetPage> {
  // bool hideTest;
  // List<List<Network>> get fillterNets =>
  //     hideTest ? [Network.netList[0]] : Network.netList;
  @override
  void initState() {
    // super.initState();
    // hideTest = Global.store.getBool('hideTestnet') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'selectAddrNet'.tr,
      hasFooter: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12, 20, 12, 40),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => MainBloc()..add(TestNetIsShowEvent()),
            )
          ],
          child: BlocBuilder<MainBloc, MainState>(builder: (context, state){
              return(
                  Column(
                    children: [
                      Layout.colStart(List.generate(state.filterNets.length, (index) {
                        var nets = Network.netList[index];
                        return Visibility(
                          child: Layout.colStart([
                            CommonText(Network.labels[index]),
                            SizedBox(
                              height: 12,
                            ),
                            Layout.colStart(List.generate(nets.length, (index) {
                              var net = nets[index];
                              return Container(
                                child: TapCardWidget(
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: CommonText.white(net.label),
                                  ),
                                  onTap: () {
                                    Get.back(result: net);
                                  },
                                ),
                                margin: EdgeInsets.only(bottom: 12),
                              );
                            }))
                          ]),
                          visible: nets.isNotEmpty,
                        );
                      })),
                      Center(
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              BlocProvider.of<MainBloc>(context).add(TestNetIsShowEvent(hideTestnet: state.hideTestnet));
                            },
                            child: Container(
                              child:
                              CommonText.grey(!state.hideTestnet ? 'hideTest'.tr : 'showTest'.tr),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              );
            }
          ),
        ),

      ),
    );
  }
}
