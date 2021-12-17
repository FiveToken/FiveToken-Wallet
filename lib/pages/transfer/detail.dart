import 'dart:math';
import 'package:fil/store/store.dart';
import 'package:fil/utils/decimal_extension.dart';
import 'package:fil/utils/num_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/models/index.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/common/time.dart';
import 'package:fil/widgets/style.dart';

class FilDetailPage extends StatefulWidget {
  @override
  State createState() => FilDetailPageState();
}

class FilDetailPageState extends State<FilDetailPage> {
  CacheMessage mes = Get.arguments;

  @override
  void initState() {
    super.initState();
  }

  void goBrowser(CacheMessage m) {
    openInBrowser($store.net.getDetailLink(m.hash));
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      grey: true,
      title: 'detail'.tr,
      hasFooter: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12, 30, 12, 0),
        child: Column(
          children: [
            Container(
              child: MessageStatusHeader(mes),
              width: double.infinity,
            ),
            SizedBox(
              height: 25,
            ),
            CommonCard(
                MessageRow(
                    label: 'amount'.tr,
                    value: formatValue()
                )
            ),
            SizedBox(
              height: 7,
            ),
            Visibility(
                visible: mes.pending != 1,
                child: CommonCard(MessageRow(
                  label: 'fee'.tr,
                  value: formatCoin(mes.fee, size: 18) + " " + $store.net.coin,
                ))),
            SizedBox(
              height: 7,
            ),
            CommonCard(Column(
              children: [
                MessageRow(label: 'from'.tr, selectable: true, value: mes.from),
                MessageRow(
                  label: 'to'.tr,
                  selectable: true,
                  value: mes.to,
                )
              ],
            )),
            SizedBox(
              height: 7,
            ),
            CommonCard(Column(
              children: [
                MessageRow(
                  label: 'cid'.tr,
                  selectable: true,
                  value: mes.hash,
                ),
                Visibility(
                  visible: mes.pending != 1,
                  child: MessageRow(
                    label: 'height'.tr,
                    value: mes.height.toString(),
                  ),
                ),
                Visibility(
                    visible: $store.net.browser != '',
                    child: GestureDetector(
                      onTap: () {
                        goBrowser(mes);
                      },
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        height: 48,
                        child: CommonText(
                          'more'.tr,
                          size: 14,
                          weight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        decoration: BoxDecoration(
                            color: CustomColor.primary,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8))),
                      ),
                    ))
              ],
            )),
          ],
        ),
      ),
    );
  }

  String formatValue(){
    bool _isToken = mes.token != null;
    if(_isToken){
      var unit = pow(10, mes.token.precision);
      var _value = double.parse(mes.value);
      var _amount = (_value/unit).toDecimal;
      var res = _amount.fmtDown(18);
      return res + " " + mes.token.symbol;
    }else{
      var res = formatCoin(mes.value, size: 18);
      return res + " " + $store.net.coin;
    }
  }
}

class MessageStatusHeader extends StatelessWidget {
  final CacheMessage mes;
  MessageStatusHeader(this.mes);
  bool get pending {
    return mes.pending == 1;
  }

  bool get successful {
    return mes.exitCode == 0 || mes.exitCode == null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(
            width: 53,
            image: AssetImage(pending
                ? 'icons/pending-res.png'
                : (successful ? 'icons/suc.png' : 'icons/fail-res.png'))),
        Container(
          child: CommonText(
            pending
                ? 'pending'.tr
                : (successful ? 'tradeSucc'.tr : 'tradeFail'.tr),
            color: pending
                ? Color(0xffE8CC5C)
                : (successful ? CustomColor.primary : CustomColor.red),
            size: 15,
            weight: FontWeight.w500,
          ),
          padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
        ),
        CommonText.grey(formatTimeByStr(mes.blockTime))
      ],
    );
  }
}

class MessageRow extends StatelessWidget {
  final bool selectable;
  final String label;
  final String value;
  final Widget append;
  MessageRow({this.label, this.value, this.append, this.selectable = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText.grey(label),
            SizedBox(
              width: 52,
            ),
            Expanded(
                child: GestureDetector(
              onTap: () {
                if (selectable && value != null) {
                  copyText(value);
                  showCustomToast('copySucc'.tr);
                }
              },
              child: Text(
                value ?? '',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.end,
              ),
            ))
          ],
        ));
  }
}
