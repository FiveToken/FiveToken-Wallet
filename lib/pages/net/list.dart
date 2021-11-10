import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/style.dart';
// import 'package:fil/index.dart';

class NetIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NetIndexStatePage();
  }
}

class NetIndexStatePage extends State<NetIndexPage> {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'net'.tr,
      footerText: 'add'.tr,
      onPressed: () {
        Get.toNamed(netAddPage).then((value) {
          setState(() {});
        });
      },
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(12, 20, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(Network.netList.length, (index) {
                var net = Network.netList[index];
                var labels = Network.labels;
                return net.length > 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(labels[index]),
                          SizedBox(
                            height: 12,
                          ),
                          Column(
                            children: List.generate(net.length, (i) {
                              var n = net[i];
                              bool custom = n.netType == 2;
                              return GestureDetector(
                                onTap: () {
                                  Get.toNamed(netAddPage, arguments: {'net': n})
                                      .then((value) {
                                    setState(() {});
                                  });
                                },
                                child: Container(
                                  height: 70,
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: CustomColor.primary,
                                      borderRadius: CustomRadius.b6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CommonText.white(
                                          custom ? n.name : n.label),
                                      custom
                                          ? Transform.translate(
                                              offset: Offset(0, 25),
                                              child: Icon(
                                                Icons.more_horiz_sharp,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            )
                                          : Icon(
                                              Icons.lock_outline,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          )
                        ],
                      )
                    : Container();
              }),
            ),
          )),
          SizedBox(
            height: 120,
          ),
        ],
      ),
    );
  }
}
