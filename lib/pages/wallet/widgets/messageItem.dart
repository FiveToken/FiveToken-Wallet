import 'package:fil/index.dart';
import 'package:flutter/cupertino.dart';

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
    var v =
        isToken ? mes.token.getFormatBalance(mes.value) : formatCoin(mes.value);
    var unit = isToken ? $store.net.coin : mes.token?.symbol;
    if (v == '0') {
      return '0 $unit';
    } else {
      return '${pending || fail ? '' : (isSend ? '-' : '+')} $v';
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
