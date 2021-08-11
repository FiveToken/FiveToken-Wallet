import 'package:fil/index.dart';
import 'package:fil/pages/main/index.dart';
import 'package:fil/store/store.dart';

var _lableStyle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(FTips1));
var _decoration = BoxDecoration(
    border: Border(
        bottom: BorderSide(
  color: Colors.grey[200],
)));
/// customize gas fee
class FilGasPage extends StatefulWidget {
  @override
  State createState() => FilGasPageState();
}

class FilGasPageState extends State<FilGasPage> {
  StoreController controller = singleStoreController;
  TextEditingController baseFeeCtrl = TextEditingController();
  int index = 0;
  void onChange(String v) {
    setState(() {});
  }

  Color getTextColor(bool filter) {
    return filter ? Colors.white : CustomColor.grey;
  }

  int get baseFee {
    try {
      var base = int.parse(singleStoreController.gas.value.baseFee);
      return base;
    } catch (e) {
      return 0;
    }
  }

  int get premium {
    try {
      var p = int.parse(singleStoreController.gas.value.premium);
      return p;
    } catch (e) {
      return 0;
    }
  }

  String get fastFeeCap {
    var feeCap = max(3 * baseFee, 5 * pow(10, 9));
    return feeCap.toString();
  }

  String get slowFeeCap {
    var base = (2.9 * baseFee).truncate();
    var feeCap = max(base, 4.9 * pow(10, 9)).truncate();
    return feeCap.toString();
  }

  String get feePrice {
    return getMarketPrice(
        singleStoreController.maxFee.replaceAll('Fil', ''), Global.price.rate);
  }

  @override
  void initState() {
    super.initState();
    index = singleStoreController.gas.value.level;
    baseFeeCtrl.addListener(() {
      var baseFeeStr = baseFeeCtrl.text.trim();
      if (baseFeeStr == '') {
        return;
      }
      try {
        var baseFeeNum = int.parse(baseFeeStr) * pow(10, 9);
        var gas = singleStoreController.gas.value;
        gas.feeCap = (premium + baseFeeNum).toString();
        gas.level = 2;
        singleStoreController.setGas(gas);
        setState(() {});
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'advanced'.tr,
      footerText: 'sure'.tr,
      onPressed: () {
        Get.back();
      },
      grey: true,
      body: Padding(
        padding: EdgeInsets.fromLTRB(12, 20, 12, 0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(12, 16, 12, 10),
              decoration: BoxDecoration(
                  borderRadius: CustomRadius.b8, color: Color(0xff5C8BCB)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText.white('fee'.tr),
                      Obx(() => CommonText.white(singleStoreController.maxFee,
                          size: 18))
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: CommonText.white(feePrice, size: 10),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText.main('feeRate'.tr),
                  // Image(
                  //   width: 20,
                  //   image: AssetImage('icons/que.png'),
                  // )
                ],
              ),
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: CustomRadius.b8,
                    color: index == 0 ? CustomColor.primary : Colors.white),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          'fast'.tr,
                          color: getTextColor(index == 0),
                        ),
                        CommonText(
                          fastFeeCap,
                          size: 10,
                          color: getTextColor(index == 0),
                        )
                      ],
                    )),
                    CommonText(
                      '<1${'minute'.tr}',
                      color: getTextColor(index == 0),
                    )
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  index = 0;
                });
                var gas = singleStoreController.gas.value;
                gas.feeCap = fastFeeCap;
                gas.level = 0;
                singleStoreController.setGas(gas);
              },
            ),
            SizedBox(
              height: 7,
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: CustomRadius.b8,
                    color: index == 1 ? CustomColor.primary : Colors.white),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          'normal'.tr,
                          color: getTextColor(index == 1),
                        ),
                        CommonText(
                          slowFeeCap,
                          size: 10,
                          color: getTextColor(index == 1),
                        ),
                      ],
                    )),
                    CommonText(
                      '<3${'minute'.tr}',
                      color: getTextColor(index == 1),
                    )
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  index = 1;
                });
                var gas = singleStoreController.gas.value;
                gas.level = 1;
                gas.feeCap = slowFeeCap;
                singleStoreController.setGas(gas);
              },
            ),
            SizedBox(
              height: 7,
            ),
            index != 2
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        index = 2;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      child: CommonText.grey('custom'.tr),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: CustomColor.primary),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.white('custom'.tr),
                        Divider(
                          color: Colors.white,
                        ),
                        CommonText.white('feeRate'.tr, size: 10),
                        Field(
                          label: '',
                          controller: baseFeeCtrl,
                          type: TextInputType.number,
                          inputFormatters: [
                            PrecisionLimitFormatter(8)
                          ],
                          extra: Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: CommonText.grey('NanoFIL', size: 10),
                          ),
                        )
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}

class MaxFee extends StatelessWidget {
  final String feeCap;
  final String gas;
  MaxFee({this.feeCap = '0', this.gas = '0'});
  @override
  Widget build(BuildContext context) {
    var _feeCap = feeCap;
    var _gas = gas;
    if (_feeCap?.trim() == '') {
      _feeCap = '0';
    }
    if (_gas?.trim() == '') {
      _gas = '0';
    }
    return Column(
      children: [
        Container(
          child: Row(
            children: [
              Text(
                'maxFee'.tr,
                style: _lableStyle,
              ),
              Text(formatFil(
                  attoFil: double.parse(_feeCap) * double.parse(_gas)))
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          decoration: _decoration,
          padding: EdgeInsets.only(bottom: 10),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            CommonText(
              'GasFeeCap($_feeCap attoFil)*Gas($_gas)',
              size: 14,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        )
      ],
    );
  }
}
