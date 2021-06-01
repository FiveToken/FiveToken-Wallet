import 'package:fil/index.dart';
import 'package:fil/store/store.dart';
import 'package:oktoast/oktoast.dart';

class FilDetailPage extends StatefulWidget {
  @override
  State createState() => FilDetailPageState();
}

class FilDetailPageState extends State<FilDetailPage> {
  MessageDetail msgDetail =
      MessageDetail(value: '0', methodName: '', allGasFee: '0');
  StoreMessage mes = Get.arguments;
  StoreController controller = Get.find();
  void getMessageDetailInfo() async {
    if (mes.pending == 1 || mes.exitCode == -1 || mes.exitCode == -2) {
      setState(() {
        msgDetail = MessageDetail(
            from: mes.from,
            to: mes.to,
            value: mes.value,
            methodName: '',
            signedCid: mes.signedCid);
      });
      return;
    }
    showCustomLoading('Loading');
    var res = await getMessageDetail(mes);
    dismissAllToast();
    if (res.height != null) {
      setState(() {
        msgDetail = res;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) => getMessageDetailInfo());
  }

  void goFilScan(MessageDetail m) {
    openInBrowser("$filscanWeb/tipset/message-detail?cid=${m.signedCid}");
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
            CommonCard(MessageRow(
              label: 'amount'.tr,
              value: atto2Fil(msgDetail.value) + ' FIL',
            )),
            SizedBox(
              height: 7,
            ),
            Visibility(
                visible: mes.pending != 1,
                child: CommonCard(MessageRow(
                  label: 'fee'.tr,
                  value: atto2Fil(msgDetail.allGasFee) + ' FIL',
                ))),
            SizedBox(
              height: 7,
            ),
            CommonCard(Column(
              children: [
                MessageRow(
                  label: 'from'.tr,
                  selectable: true,
                  value: msgDetail.from,
                ),
                MessageRow(
                  label: 'to'.tr,
                  selectable: true,
                  value: msgDetail.to,
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
                  value: msgDetail.signedCid,
                ),
                Visibility(
                  visible: mes.pending != 1,
                  child: MessageRow(
                    label: 'height'.tr,
                    value: msgDetail.height.toString(),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    goFilScan(msgDetail);
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
                )
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class MessageStatusHeader extends StatelessWidget {
  final StoreMessage mes;
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
                if (selectable) {
                  copyText(value);
                  showCustomToast('copySucc'.tr);
                }
              },
              child: Text(
                value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.end,
              ),
            ))
          ],
        ));
  }
}
