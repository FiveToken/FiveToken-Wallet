import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';

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
  bool hideTest = false;
  List<List<Network>> get filterNets =>
      hideTest ? [Network.netList[0]] : Network.netList;
  @override
  void initState() {
    super.initState();
    setList();
  }

  void setList() {
    currentMneWallets = OpenedBox.walletInstance.values.where((wal) {
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
        child: Column(
          children: [
            Column(
              children: List.generate(filterNets.length, (index) {
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
                            .where((wallet) =>
                                wallet.addressType == net.addressType)
                            .toList()[0];
                        var addr = net.prefix + wal.address;
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
                                        str: addr, headLen: 11, tailLen: 8),
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
                setState(() {
                  hideTest = !hideTest;
                });
              },
              child: Container(
                child:
                    CommonText.grey(!hideTest ? 'hideTest'.tr : 'showTest'.tr),
              ),
            )
          ],
        ),
      ),
    );
  }
}
