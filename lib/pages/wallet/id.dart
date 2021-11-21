
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/layout.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/routes/path.dart';
// import 'package:fil/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IdWalletPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IdWalletPageState();
  }
}

class IdWalletPageState extends State<IdWalletPage> {
  List<List<ChainWallet>> list = [];
  String groupHash = Get.arguments['groupHash'];
  List<ChainWallet> currentMneWallets = [];
  @override
  void initState() {
    super.initState();
    setList();
  }

  void setList() {
    currentMneWallets = OpenedBox.get<ChainWallet>().values.where((wal) {
      return wal.groupHash == groupHash;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'idWallet'.tr,
      hasFooter: false,
      body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12, 20, 12, 40),
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) => MainBloc()..add(TestNetIsShowEvent()))
            ],
            child: BlocBuilder<MainBloc, MainState>(
              builder: (context, state) {
                return (Column(
                  children: [
                    Column(
                      children: List.generate(state.filterNets.length, (index) {
                        var nets = Network.netList[index];
                        return Visibility(
                          child: Layout.colStart([
                            CommonText(Network.labels[index]),
                            SizedBox(
                              height: 12,
                            ),
                            Column(
                              children: List.generate(nets.length, (i) {
                                var net = nets[i];
                                var wal = currentMneWallets
                                    .where((wallet) => wallet.rpc == net.rpc)
                                    .toList()[0];
                                var addr = wal.addr;
                                return GestureDetector(
                                  onTap: () {
                                    Global.cacheWallet = wal;
                                    Get.toNamed(walletMangePage,
                                        arguments: {'net': net, 'wallet': wal});
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    margin: EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                        color: CustomColor.primary,
                                        borderRadius: CustomRadius.b6),
                                    child: Layout.colStart([
                                      CommonText.white(net?.label ?? ""),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Layout.rowBetween([
                                        CommonText.white(
                                            dotString(
                                                str: addr,
                                                headLen: 11,
                                                tailLen: 8),
                                            size: 12),
                                        Transform.translate(
                                            offset: Offset(0, 5),
                                            child: Icon(
                                              Icons.more_horiz_sharp,
                                              color: Colors.white,
                                              size: 16,
                                            ))
                                      ])
                                    ]),
                                  ),
                                );
                              }),
                            )
                          ]),
                          visible: nets.length > 0,
                        );
                      }),
                    ),
                    GestureDetector(
                      onTap: () {
                        BlocProvider.of<MainBloc>(context).add(TestNetIsShowEvent(hideTestnet: state.hideTestnet));
                      },
                      child: Container(
                        child: CommonText.grey(
                            !state.hideTestnet ? 'hideTest'.tr : 'showTest'.tr),
                      ),
                    )
                  ],
                ));
              },
            ),
          )
          ),
    );
  }
}
