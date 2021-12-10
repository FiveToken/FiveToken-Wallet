// import 'package:fil/index.dart';
import 'package:fil/bloc/address/address_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/index.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/style.dart';
import  'package:fil/init/hive.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/services.dart';
import 'package:fil/pages/address/index.dart';
import 'package:fil/pages/other/scan.dart';

class AddressBookAddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddressBookAddPageState();
  }
}

class AddressBookAddPageState extends State<AddressBookAddPage> {
  TextEditingController addrCtrl = TextEditingController();
  TextEditingController nameCtrl = TextEditingController();
  ContactAddress addr;
  var box = OpenedBox.addressBookInsance;
  int mode = 0;
  // Network net = $store.net;
  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments['mode'] != null) {
      addr = Get.arguments['addr'] as ContactAddress;
      mode = 1;
      addrCtrl.text = addr.address;
      nameCtrl.text = addr.label;
    }
  }

  Future<bool> checkValid(Network net) async {
    var addr = addrCtrl.text.trim();
    var name = nameCtrl.text.trim();
    if(addr==''){
      showCustomError('validAddress'.tr);
      return false;
    }
    bool valid = await isValidChainAddress(addr, net);
    if (!valid) {
      showCustomError('enterValidAddr'.tr);
      return false;
    }
    if (name == '' || name.length > 20) {
      showCustomError('enterTag'.tr);
      return false;
    }
    if (box.containsKey('${addr}_${net.rpc}') && !edit) {
      showCustomError('errorExist'.tr);
      return false;
    }
    return true;
  }

  Future<void> handleConfirm(Network net) async {
    bool valid = await checkValid(net);
    if (!valid) {
      return;
    }
    if (net.rpc != $store.net.rpc) {
      showDialog(net);
    } else {
      confirmAdd(net);
    }
  }

  void confirmAdd(Network net) {
    var address = addrCtrl.text.trim();
    var label = nameCtrl.text.trim();
    if (edit) {
      box.delete(addr.key);
    }
    var v = ContactAddress(label: label, address: address, rpc: net.rpc);
    box.put(v.key, v);
    showCustomToast(!edit ? 'addAddrSucc'.tr : 'changeAddrSucc'.tr);
    Get.back();
  }

  bool get edit {
    return addr != null;
  }

  void showDialog(Network net) {
    showCustomDialog(
        context,
        Column(
          children: [
            CommonTitle(
              'addAddrBook'.tr,
              showDelete: true,
            ),
            Container(
                child: CommonText.center(trParams('netNotMatch'.tr,
                    {'currentNet': $store.net.label, 'newNet': net.label})),
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                )),
            Divider(
              height: 1,
            ),
            Container(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      child: CommonText(
                        'cancel'.tr,
                      ),
                      alignment: Alignment.center,
                    ),
                    onTap: () {
                      Get.back();
                    },
                  )),
                  Container(
                    width: .2,
                    color: CustomColor.grey,
                  ),
                  Expanded(
                      child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      child: CommonText(
                        'add'.tr,
                        color: CustomColor.primary,
                      ),
                      alignment: Alignment.center,
                    ),
                    onTap: () {
                      Get.back();
                      confirmAdd(net);
                    },
                  )),
                ],
              ),
            )
          ],
        ));
  }

  void handleScan(Network net) {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Connect})
        .then((scanResult) async {
      if (scanResult != '') {
        bool valid = await isValidChainAddress(scanResult, net);
        if (valid) {
          addrCtrl.text = scanResult;
        } else {
          showCustomError('wrongAddr'.tr);
        }
      }
    });
  }
  void onChange(BuildContext context, Network net){
    BlocProvider.of<AddressBloc>(context)..add(AddressListEvent(network: net));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AddressBloc()..add(AddressListEvent(network: $store.net)),
        child: BlocBuilder<AddressBloc, AddressState>(builder: (context, state){
             return CommonScaffold(
               title: !edit ? 'addAddr'.tr : 'manageAddr'.tr,
               footerText: !edit ? 'add'.tr : 'save'.tr,
               grey: true,
               onPressed: ()=>{handleConfirm(state.net)},
               actions: [
                 Padding(
                   child: GestureDetector(
                       onTap: ()=>{ handleScan(state.net)},
                       child: Image(
                         width: 20,
                         image: AssetImage('icons/scan.png'),
                       )),
                   padding: EdgeInsets.only(right: 10),
                 )
               ],
               body: Padding(
                 child: Column(
                   children: [
                     NetEntranceWidget(
                         network: state.net,
                         onChange: (net)=>{onChange(context, net)}
                     ),
                     SizedBox(
                       height: 12,
                     ),
                     Field(
                       controller: addrCtrl,
                       label: 'contactAddr'.tr,
                       append: GestureDetector(
                         child: Image(width: 20, image: AssetImage('icons/cop.png')),
                         onTap: () async {
                           var data = await Clipboard.getData(Clipboard.kTextPlain);
                           addrCtrl.text = data.text;
                         },
                       ),
                     ),
                     SizedBox(
                       height: 20,
                     ),
                     Field(
                       controller: nameCtrl,
                       maxLength: 20,
                       label: 'remark'.tr,
                     ),
                   ],
                 ),
                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
               ),
             );
        }),
    );
  }
}
