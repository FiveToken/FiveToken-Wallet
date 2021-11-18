// import 'package:fil/index.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/common/global.dart';
import 'package:fil/widgets/bottomSheet.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/layout.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/store/store.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/actions/event.dart';
import 'package:fil/utils/enum.dart';

class NetSelect extends StatelessWidget {
  @override
  build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if ($store.wal.type != WalletType.id) {
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
                                        Global.eventBus
                                            .fire(ShouldRefreshEvent());
                                        Global.store.setString(
                                            'currentWalletAddress', l[0].key);
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
              visible: $store.wal.type == WalletType.id,
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
