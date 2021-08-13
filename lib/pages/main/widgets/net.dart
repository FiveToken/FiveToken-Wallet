import 'package:fil/index.dart';

class NetSelect extends StatelessWidget {
  @override
  build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if ($store.wal.type != 0) {
          return;
        }
        showCustomModalBottomSheet(
            shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
            context: context,
            builder: (BuildContext context) {
              return ConstrainedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonTitle(
                        'net'.tr,
                        showDelete: true,
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                        child: Layout.colStart(
                            List.generate(Network.netList.length, (index) {
                          var labels = Network.labels;
                          var nets = Network.netList[index];
                          return Visibility(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(labels[index]),
                                SizedBox(
                                  height: 12,
                                ),
                                Layout.colStart(List.generate(nets.length, (i) {
                                  var net = nets[i];
                                  var active = $store.net.rpc == net.rpc;
                                  return GestureDetector(
                                    onTap: () {
                                      var l = OpenedBox.walletInstance.values
                                          .where((wal) =>
                                              wal.rpc == net.rpc &&
                                              wal.groupHash ==
                                                  $store.wal.groupHash)
                                          .toList();
                                      if (l.isNotEmpty) {
                                        $store.setNet(net);
                                        $store.setWallet(l[0]);
                                        Global.eventBus.fire(WalletChangeEvent());
                                        Global.store.setString(
                                            'currentWalletAddress',
                                            l[0].address);
                                        Global.store.setString(
                                            'activeNetwork', net.rpc);
                                      }
                                      Get.back();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            color: active
                                                ? Colors.white
                                                : Colors.transparent,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          CommonText(
                                            net.label,
                                            color: active
                                                ? Colors.white
                                                : Colors.black,
                                          )
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius: CustomRadius.b6,
                                          color: active
                                              ? CustomColor.primary
                                              : Colors.white),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      margin: EdgeInsets.only(bottom: 12),
                                    ),
                                  );
                                })),
                              ],
                            ),
                            visible: nets.isNotEmpty,
                          );
                        })),
                      ))
                    ],
                  ),
                  constraints: BoxConstraints(maxHeight: 800));
            });
      },
      child: Column(
        children: [
          CommonText(
            'wallet'.tr,
            size: 18,
            weight: FontWeight.w500,
          ),
          Obx(() => Visibility(
              visible: $store.wal.type == 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: Color(int.parse($store.net.color ?? '0xff000000')),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Obx(() => CommonText.grey($store.net.label, size: 12))
                ],
              )))
        ],
      ),
    );
  }
}
