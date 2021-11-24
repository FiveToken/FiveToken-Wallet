import 'package:fil/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/layout.dart';
import 'package:fil/routes/path.dart';

class ImportIndexPage extends StatelessWidget {
  final int type = Get.arguments['type']; //1 mne 2 privatekey
  bool get isMne => type == WalletType.mne;
  void go(int type, Network net) {
    Get.toNamed(isMne ? importMnePage : importPrivateKeyPage,
        arguments: {'type': type, 'net': net});
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: isMne ? 'importMne'.tr : 'importPk'.tr,
      hasFooter: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12, 20, 12, 40),
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Visibility(
              child: TapCardWidget(
                Layout.rowBetween([
                  CommonText.white('idWallet'.tr),
                  Image(width: 18, image: AssetImage('icons/right-w.png'))
                ]),
                onTap: () {
                  go(WalletType.id, null);
                },
              ),
              visible: isMne,
            ),
            SizedBox(
              height: 12,
            ),
            Layout.colStart(List.generate(Network.netList.length, (index) {
              var nets = Network.netList[index];
              return Visibility(
                  visible: nets.isNotEmpty,
                  child: Layout.colStart([
                    CommonText(Network.labels[index]),
                    SizedBox(
                      height: 12,
                    ),
                    Column(
                      children: List.generate(nets.length, (index) {
                        var net = nets[index];
                        return Container(
                          child: TapCardWidget(
                            Layout.rowBetween([
                              CommonText.white(net.label),
                              Image(
                                  width: 18,
                                  image: AssetImage('icons/right-w.png'))
                            ]),
                            onTap: () {
                              go(type, net);
                            },
                          ),
                          margin: EdgeInsets.only(bottom: 12),
                        );
                      }),
                    )
                  ]));
            }))
          ],
        ),
      ),
    );
  }
}
