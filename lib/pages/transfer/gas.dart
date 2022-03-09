import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:fil/bloc/gas/gas_bloc.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/common/formatter.dart';
import 'package:fil/config/config.dart';
import 'package:fil/models/index.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/services.dart';

class ChainGasPage extends StatefulWidget {
  @override
  State createState() => ChainGasPageState();
}

// Page of chain Gas
class ChainGasPageState extends State<ChainGasPage> {
  TextEditingController maxPriorityFeeCtrl = TextEditingController();
  TextEditingController maxFeePerGasCtrl = TextEditingController();
  TextEditingController gasFeeCapCtrl = TextEditingController();
  TextEditingController gasPriceCtrl = TextEditingController();
  TextEditingController gasPremiumCtrl = TextEditingController();
  TextEditingController gasLimitCtrl = TextEditingController();

  String rpcType = '';
  String activeTab = '';
  String activeGear = '';
  ChainGas storeGas = $store.gas;

  String get handlingFee {
    var fee = $store.gas.handlingFee;
    var unit = BigInt.from(pow(10, 18));
    var res = (BigInt.parse(fee) / unit).toStringAsFixed(8);
    return res;
  }

  @override
  void initState() {
    super.initState();
    if (($store.net.chain == 'eth') && ($store.net.net == 'main')) {
      rpcType = RpcType.ethereumMain;
      activeTab = storeGas.isCustomize ? GasTabBars.customize : GasTabBars.gearSelection;
      activeGear = storeGas.isCustomize ? '' : GasGear.middle;
    } else if ($store.net.chain == 'filecoin') {
      rpcType = RpcType.fileCoin;
      activeTab = GasTabBars.customize;
    } else {
      rpcType = RpcType.ethereumOthers;
      activeTab = GasTabBars.customize;
    }
    initGas(rpcType);
  }

  /*
  * fee initialization
  * */
  void initGas(String rpcType) {
    var unit = BigInt.from(pow(10, 9));
    maxPriorityFeeCtrl.text =
        (BigInt.parse(storeGas.maxPriorityFee) / unit).toString();
    maxFeePerGasCtrl.text =
        (BigInt.parse(storeGas.maxFeePerGas) / unit).toString();
    gasPremiumCtrl.text = storeGas.gasPremium;
    gasFeeCapCtrl.text = storeGas.gasFeeCap;
    gasPriceCtrl.text = (BigInt.parse(storeGas.gasPrice) / unit).toString();
    gasLimitCtrl.text = storeGas.gasLimit.toString();
  }

  void handleSubmit(BuildContext context,tab) {
    var maxPriorityFee = maxPriorityFeeCtrl.text.trim();
    var maxFeePerGas = maxFeePerGasCtrl.text.trim();
    var gasFeeCap = gasFeeCapCtrl.text.trim();
    var gasPrice = gasPriceCtrl.text.trim();
    var gasPremium = gasPremiumCtrl.text.trim();
    var gasLimit = gasLimitCtrl.text.trim();

    if (rpcType == RpcType.ethereumMain) {
      if (maxPriorityFee == '' || maxFeePerGas == '' || gasLimit == '') {
        showCustomError('errorSetGas'.tr);
        return;
      }
    } else if (rpcType == RpcType.fileCoin) {
      if (gasFeeCap == '' || gasPremium == '' || gasLimit == '') {
        showCustomError('errorSetGas'.tr);
        return;
      }
    } else {
      if (gasPrice == '' || gasLimit == '') {
        showCustomError('errorSetGas'.tr);
        return;
      }
    }

    var unit = Decimal.fromInt(pow(10,9).toInt());
    var _maxFeePerGas = Decimal.parse(maxFeePerGas) * unit;
    var _maxPriorityFee = Decimal.parse(maxPriorityFee) * unit;
    var _gasPrice = Decimal.parse(gasPrice) * unit;
    var _gas = {
      "maxPriorityFee": _maxPriorityFee.toString(),
      "maxFeePerGas": _maxFeePerGas.toString(),
      "gasLimit": int.parse(gasLimit),
      "gasPremium": gasPremium,
      "gasPrice": _gasPrice.toString(),
      "rpcType": rpcType,
      "gasFeeCap": gasFeeCap,
      "baseFeePerGas":$store.gas.baseFeePerGas,
      "baseMaxPriorityFee":$store.gas.baseMaxPriorityFee,
      "isCustomize": tab == GasTabBars.customize
    };
    ChainGas gas = ChainGas.fromJson(_gas);
    $store.setGas(gas);
    Get.back();

  }
  /*
  * Get a fee based on the gear
  * @param {string} gear: selected gear
  * */
  String getGearHandlingFee(String gear){
    try{
      ChainGas storeGas = $store.gas;
      String fee = '0';
      double times;
      switch(gear){
        case GasGear.high:
          times = Config.highMaxPriorityFeePerGas;
          break;
        case GasGear.middle:
          times = Config.middleMaxPriorityFeePerGas;
          break;
        case GasGear.low:
          times = Config.lowMaxPriorityFeePerGas;
          break;
      }
      String maxPriorityFee = getMaxPriorityFee(storeGas.baseMaxPriorityFee,times);
      String maxFeePerGas = getMaxFeePerGas(storeGas.baseFeePerGas,maxPriorityFee);
      var feeNum = BigInt.parse(maxFeePerGas) * BigInt.from(storeGas.gasLimit);
      var unit = BigInt.from(pow(10, 18));
      fee = (feeNum / unit).toStringAsFixed(8);
      return fee;
    }catch(error){
      return '0';
    }
  }
  /*
  * Transfer fee level adjustment
  * */
  void changeGear(String gear, BuildContext ctx){
    ChainGas storeGas = $store.gas;
    String fee = getGearHandlingFee(gear);
    BlocProvider.of<GasBloc>(ctx)..add(UpdateGasGearEvent(gear))..add(UpdateHandlingFeeEvent(fee));
    var unit = BigInt.from(pow(10, 9));
    double times;
    switch(gear){
      case GasGear.high:
        times = Config.highMaxPriorityFeePerGas;
        break;
      case GasGear.middle:
        times = Config.middleMaxPriorityFeePerGas;
        break;
      case GasGear.low:
        times = Config.lowMaxPriorityFeePerGas;
        break;
    }
    String maxPriorityFee = getMaxPriorityFee(storeGas.baseMaxPriorityFee,times);
    String maxFeePerGas = getMaxFeePerGas(storeGas.baseFeePerGas,maxPriorityFee);
    String _maxPriorityFee = (BigInt.parse(maxPriorityFee) / unit).toString();
    String _maxFeePerGas = (BigInt.parse(maxFeePerGas) / unit).toString();
    maxPriorityFeeCtrl.text = _maxPriorityFee;
    maxFeePerGasCtrl.text = _maxFeePerGas;

  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).viewInsets.bottom;
    return BlocProvider(
      create: (context) => GasBloc()..add(UpdateHandlingFeeEvent(handlingFee))..add(UpdateTabsEvent(activeTab))..add(UpdateGasGearEvent(activeGear)),
      child: BlocBuilder<GasBloc, GasState>(builder: (ctx, state) {
        return CommonScaffold(
            title: 'advanced'.tr,
            footerText: 'sure'.tr,
            backFn:(){
              Navigator.popUntil(context, (route) =>route.settings.name == transferConfrimPage);
            },
            grey: true,
            onPressed: () {
              handleSubmit(context,state.tab);
            },
            body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(12, 20, 12, h + 100),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(12, 16, 12, 10),
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                    decoration: BoxDecoration(
                        borderRadius: CustomRadius.b8,
                        color: Color(0xff5C8BCB)
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonText.white('fee'.tr),
                            CommonText.white(
                                state.handlingFee + $store.net.coin,
                                size: 18
                            )
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                      visible: rpcType == RpcType.ethereumMain,
                      child: Container(
                        width: 240,
                        height: 40,
                        alignment: Alignment.center,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Color(0xffe2e2e2)),
                        child: Flex(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                  flex:0,
                                  child: TabBarItem(
                                      onTap: () {
                                        BlocProvider.of<GasBloc>(ctx).add(UpdateTabsEvent(GasTabBars.gearSelection));
                                      },
                                      label:'gearSelection'.tr,
                                      active: state.tab == GasTabBars.gearSelection
                                  )
                              ),
                              Expanded(
                                  flex:0,
                                  child: TabBarItem(
                                      onTap: () {
                                        BlocProvider.of<GasBloc>(ctx).add(UpdateTabsEvent(GasTabBars.customize));
                                      },
                                      label:'custom'.tr,
                                      active: state.tab == GasTabBars.customize
                                  )
                              ),
                            ]
                        ),
                      ),
                  ),
                  Visibility(
                    visible: state.tab == GasTabBars.gearSelection,
                      child: Column(
                        children: [
                          GearItem(
                            onTap: (){
                              changeGear(GasGear.high,ctx);
                            },
                            selected: state.gear == GasGear.high,
                            text: 'high'.tr,
                            fee:getGearHandlingFee(GasGear.high),
                            time: '30s',
                          ),
                          SizedBox(height: 10),
                          GearItem(
                            onTap: (){
                              changeGear(GasGear.middle,ctx);
                            },
                            selected: state.gear == GasGear.middle,
                            text: 'middle'.tr,
                            fee:getGearHandlingFee(GasGear.middle),
                            time: '3 min',
                          ),
                          SizedBox(height: 10),
                          GearItem(
                            onTap: (){
                              changeGear(GasGear.low,ctx);
                            },
                            selected: state.gear == GasGear.low,
                            text: 'low'.tr,
                            fee:getGearHandlingFee(GasGear.low),
                            time: '10 min',
                          ),
                        ],
                      ),
                  ),
                  Visibility(
                    visible: state.tab == GasTabBars.customize,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CommonText.main('feeRate'.tr),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          _getGasWidget()
                        ],
                      )
                  ),

                ],
              ),
            ));
      }),
    );
  }

  /*
  * Get the fee component based on the network type
  * */
  Widget _getGasWidget() {
    return rpcType == RpcType.ethereumMain
        ? _ethMainGas()
        : (rpcType == RpcType.fileCoin ? _fileCoinGas() : _ethOthersGas());
  }

  Widget _fileCoinGas() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: CustomColor.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText.white('GasFeeCap', size: 10),
          Field(
            label: '',
            controller: gasFeeCapCtrl,
            extra: Padding(
              padding: EdgeInsets.only(right: 12),
              child: CommonText('attoFIL'),
            ),
            type: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [PrecisionLimitFormatter(18)],
          ),
          CommonText.white('GasPremium', size: 10),
          Field(
            label: '',
            controller: gasPremiumCtrl,
            extra: Padding(
              padding: EdgeInsets.only(right: 12),
              child: CommonText('attoFIL'),
            ),
            type: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [PrecisionLimitFormatter(18)],
          ),
          CommonText.white('GasLimit', size: 10),
          Field(
            label: '',
            controller: gasLimitCtrl,
            type: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [PrecisionLimitFormatter(18)],
          )
        ],
      ),
    );
  }

  Widget _ethMainGas() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: CustomColor.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText.white('Max priority fee(Gwei)', size: 10),
          Field(
            label: '',
            controller: maxPriorityFeeCtrl,
            type: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [PrecisionLimitFormatter(18)],
          ),
          SizedBox(
            height: 10,
          ),
          CommonText.white('Max fee(Gwei)', size: 10),
          Field(
            label: '',
            controller: maxFeePerGasCtrl,
            type: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [PrecisionLimitFormatter(18)],
          ),
          SizedBox(
            height: 10,
          ),
          CommonText.white('GasLimit', size: 10),
          Field(
            label: '',
            controller: gasLimitCtrl,
            type: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [PrecisionLimitFormatter(18)],
          )
        ],
      ),
    );
  }

  Widget _ethOthersGas() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: CustomColor.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText.white('GasPrice', size: 10),
          Field(
            label: '',
            controller: gasPriceCtrl,
            type: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [PrecisionLimitFormatter(18)],
            extra: Padding(
              padding: EdgeInsets.only(right: 12),
              child: CommonText('gwei'),
            ),
          ),
          CommonText.white('GasLimit', size: 10),
          Field(
            label: '',
            controller: gasLimitCtrl,
            type: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [PrecisionLimitFormatter(18)],
          )
        ],
      ),
    );
  }
}

class TabBarItem extends StatelessWidget{
  final Noop onTap;
  final String label;
  final bool active;
  TabBarItem({
    @required this.onTap,
    @required this.active,
    @required this.label
  });
  @override
  Widget build(BuildContext context){
    return GestureDetector(
        onTap: () => {
          onTap()
        },
        child: Container(
            width: 100,
            height: 30,
            child: active ? CommonText.white(label) : CommonText.grey(label),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: active ? Color(0xff060606): Color(0xffe2e2e2)
            )
        )
    );
  }
}

class GearItem extends StatelessWidget{
  final Noop onTap;
  final String text;
  final String fee;
  final String time;
  final bool selected;
  GearItem({
    @required this.onTap,
    @required this.text,
    @required this.fee,
    @required this.time,
    @required this.selected
  });
  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: ()=>{
        onTap()
      },
      child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration:BoxDecoration(
              border: Border.all(color: Color(0xffe2e2e2), width: 1),
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              )
          ),
          child: Flex(
            direction:Axis.horizontal,
            children: [
              Expanded(
                flex: 0,
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Visibility(
                    visible: selected,
                    child: Image(
                        width: 30,
                        image: AssetImage('icons/succ.png')
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                        text,
                        align:TextAlign.start
                    ),
                    CommonText(
                        fee,
                        align:TextAlign.start
                    ),
                  ],
                ),
              ),
              Expanded(
                  flex: 0,
                  child: CommonText(
                      time,
                      align:TextAlign.end
                  )
              )
            ],
          )
      ),
    );
  }
}




