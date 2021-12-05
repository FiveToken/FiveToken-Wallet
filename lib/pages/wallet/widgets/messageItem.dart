// import 'package:fil/index.dart';
import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:fil/utils/decimal_extension.dart';
import 'package:fil/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/layout.dart';
import 'package:fil/widgets/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/store/store.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/models/index.dart';
import 'package:fil/pages/wallet/main.dart';

class MessageItem extends StatelessWidget {
  final CacheMessage mes;
  MessageItem(this.mes);
  bool get isSend {
    return mes.from == $store.wal.addr;
  }

  bool get fail {
    return mes.exitCode != 0;
  }

  bool get pending {
    return mes.pending == 1;
  }

  String get addr {
    var pre = isSend ? 'to'.tr : 'from'.tr;
    var address = isSend ? mes.to : mes.from;
    return '$pre ${dotString(str: address)}';
  }

  bool get isToken => mes.token != null;
  String get value {
    if(isToken){
      var amount = Decimal.parse(mes.value);
      var unit = Decimal.fromInt(pow(10, mes.token.precision));
      var _decimal = (amount / unit).toString().toDecimal;
      var res = _decimal.fmtDown(8);
      var _isSend = pending || fail ? '' : (isSend ? '-' : '+');
      return _isSend + res + ' ' + mes.token.symbol;
    }else{
      var _value = formatCoin(mes.value,size:8,min:0.00000001) + ' ' + $store.net.coin;
      var _isSend = pending || fail ? '' : (isSend ? '-' : '+');
      return _isSend + ' ' + _value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.toNamed(filDetailPage, arguments: mes);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Row(
          children: [
            IconBtn(
              size: 32,
              color: Color(pending
                  ? 0xffE8CC5C
                  : (fail
                      ? 0xffB4B5B7
                      : isSend
                          ? 0xff5C8BCB
                          : 0xff5CC1CB)),
              path: (pending
                  ? 'pending.png'
                  : (fail ? 'fail.png' : (isSend ? 'rec.png' : 'send.png'))),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Layout.colStart([
                CommonText.main(
                  pending
                      ? 'pending'.tr
                      : (fail
                          ? 'fail'.tr
                          : isSend
                              ? 'sended'.tr
                              : 'reced'.tr),
                  size: 15,
                ),
                CommonText.grey(addr, size: 10),
              ]),
            ),
            CommonText(
              value,
              size: 15,
              color: CustomColor.primary,
              weight: FontWeight.w500,
            )
          ],
        ),
      ),
    );
  }
}
