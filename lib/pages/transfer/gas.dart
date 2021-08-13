import 'package:fil/index.dart';
import 'package:fil/store/store.dart';

/// customize gas fee
class FilGasPage extends StatefulWidget {
  @override
  State createState() => FilGasPageState();
}

class FilGasPageState extends State<FilGasPage> {
  TextEditingController feeCapCtrl = TextEditingController();
  TextEditingController gasLimitCtrl = TextEditingController();
  int index = 0;
  ChainGas chainGas = ChainGas();
  Color getTextColor(bool filter) {
    return filter ? Colors.white : CustomColor.grey;
  }

  bool get isEth => $store.net.addressType == 'eth';

  ChainGas get gas {
    return $store.g.value;
  }

  String get fastFeeCap {
    return chainGas.gasPrice;
  }

  String get slowFeeCap {
    try {
      var feeCapNum = int.parse(chainGas.gasPrice);
      var feeCap = (0.9 * feeCapNum).truncate().toString();
      return feeCap.toString();
    } catch (e) {
      return chainGas.gasPrice;
    }
  }

  void handleSubmit(BuildContext context) {
    final feeCap = feeCapCtrl.text.trim();
    final gasLimit = gasLimitCtrl.text.trim();
    var feeCapNum = double.parse(feeCap);
    if (feeCap == '' || gasLimit == '') {
      showCustomError('errorSetGas'.tr);
      return;
    }
    if (index == 2) {
      $store.setGas(ChainGas(
          level: 2,
          gasLimit: double.tryParse(gasLimit).truncate(),
          gasPrice: isEth
              ? (BigInt.from(pow(10, 9)) * BigInt.from(feeCapNum)).toString()
              : feeCapNum.truncate().toString(),
          gasPremium:
              isEth ? chainGas.gasPremium : (feeCapNum - 100).toString()));
    }
    unFocusOf(context);
    Get.back();
  }

  @override
  void initState() {
    super.initState();
    index = $store.gas.level;
    if (Get.arguments != null && Get.arguments['gas'] != null) {
      chainGas = Get.arguments['gas'] as ChainGas;
      syncGas(chainGas);
    }
    if (index == 2) {
      syncGas($store.gas);
    }
  }

  void syncGas(ChainGas g) {
    feeCapCtrl.text = g.gasPrice;
    gasLimitCtrl.text = g.gasLimit.toString();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).viewInsets.bottom;
    return CommonScaffold(
      title: 'advanced'.tr,
      footerText: 'sure'.tr,
      grey: true,
      onPressed: () {
        handleSubmit(context);
      },
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12, 20, 12, h + 100),
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
                      Obx(() => CommonText.white($store.gas.maxFee, size: 18))
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  // Container(
                  //   alignment: Alignment.bottomRight,
                  //   child: CommonText.white(feePrice, size: 10),
                  // )
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
                  //   image: AssetImage('images/que.png'),
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
                          formatCoin(chainGas.fast.gasPrice, size: 5),
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
                  $store.setGas(chainGas.fast);
                });
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
                          formatCoin(chainGas.slow.gasPrice, size: 5),
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
                  $store.setGas(chainGas.slow);
                });
              },
            ),
            SizedBox(
              height: 7,
            ),
            index != 2
                ? GestureDetector(
                    onTap: () {
                      var n = double.parse(chainGas.gasPrice) / pow(10, 9);
                      if ($store.net.addressType == 'eth') {
                        if (n > 1) {
                          feeCapCtrl.text = n.truncate().toString();
                        } else {
                          feeCapCtrl.text = n.toStringAsFixed(1);
                        }
                      } else {
                        feeCapCtrl.text = chainGas.gasPrice;
                      }
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
                        CommonText.white('GasFeeCap', size: 10),
                        Field(
                          label: '',
                          controller: feeCapCtrl,
                          type: TextInputType.number,
                          extra: Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: CommonText($store.net.addressType == 'eth'
                                ? 'gwei'
                                : 'attoFIL'),
                          ),
                          inputFormatters: [PrecisionLimitFormatter(8)],
                        ),
                        CommonText.white('GasLimit', size: 10),
                        Field(
                          label: '',
                          controller: gasLimitCtrl,
                          type: TextInputType.number,
                          inputFormatters: [PrecisionLimitFormatter(8)],
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
