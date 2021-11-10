// import 'package:fil/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/pages/transfer/transfer.dart';
import 'package:fbutton/fbutton.dart';
import 'package:fil/models/index.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/common/walletConnect.dart';

class ConnectWallet extends StatelessWidget {
  final WCMeta meta;
  final Noop onConnect;
  final Noop onCancel;
  final Widget footer;
  ConnectWallet({this.meta, this.onCancel, this.onConnect, this.footer});
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 800),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 100,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Image.network(
                meta.icons[0],
                errorBuilder: (BuildContext context, Object object,
                    StackTrace stackTrace) {
                  return Image(
                    image: AssetImage('icons/wc-blue.png'),
                  );
                },
              ),
            ),
            CommonText.center(meta.name, size: 16, color: Colors.black),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CommonText(meta.description),
            ),
            footer ??
                Container(
                  child: Row(
                    children: [
                      Expanded(
                          child: FButton(
                        alignment: Alignment.center,
                        height: 40,
                        onPressed: () {
                          Get.back();
                          onCancel();
                        },
                        strokeWidth: .5,
                        strokeColor: Color(0xffcccccc),
                        //style: TextStyle(color: Colors.white),
                        corner: FCorner.all(6),
                        //color: Colors.red,
                        text: 'cancel'.tr,
                      )),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          child: FButton(
                        text: 'connect'.tr,
                        alignment: Alignment.center,
                        onPressed: () {
                          Get.back();
                          onConnect();
                        },
                        height: 40,
                        style: TextStyle(color: Colors.white),
                        color: CustomColor.primary,
                        corner: FCorner.all(6),
                      )),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  margin: EdgeInsets.only(bottom: 40),
                )
          ],
        ),
      ),
    );
  }
}

class ConfirmMessageSheet extends StatelessWidget {
  final String address;
  final String to;
  final String maxFee;
  final String value;
  final WCSession session;
  final JsonRpc rpc;
  final Noop onApprove;
  final Noop onReject;
  ConfirmMessageSheet(
      {this.address,
      this.to,
      this.maxFee,
      this.value,
      this.session,
      this.rpc,
      this.onApprove,
      this.onReject});
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 30),
        child: ConfirmSheet(
          from: address,
          to: to,
          gas: maxFee,
          value: value,
          footer: Row(
            children: [
              Expanded(
                  child: FButton(
                alignment: Alignment.center,
                height: 40,
                onPressed: () {
                  Get.back();
                  onReject();
                },
                strokeWidth: .5,
                strokeColor: Color(0xffcccccc),
                corner: FCorner.all(6),
                text: 'reject'.tr,
              )),
              SizedBox(
                width: 20,
              ),
              Expanded(
                  child: FButton(
                text: 'approve'.tr,
                alignment: Alignment.center,
                onPressed: () {
                  Get.back();
                  onApprove();
                },
                height: 40,
                style: TextStyle(color: Colors.white),
                color: CustomColor.primary,
                corner: FCorner.all(6),
              )),
            ],
          ),
        ),
      ),
      constraints: BoxConstraints(maxHeight: 800),
    );
  }
}
