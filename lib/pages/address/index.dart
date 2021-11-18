
import 'package:fil/bloc/address/address_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/layout.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/pages/wallet/select.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/store/store.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/index.dart';
// import 'package:fil/index.dart';

class AddressBookIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddressBookIndexPageState();
  }
}

class AddressBookIndexPageState extends State<AddressBookIndexPage> {
  var box = OpenedBox.addressBookInsance;

  void onChanges(context,  net){
    BlocProvider.of<AddressBloc>(context).add(AddressListEvent(network: net));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddressBloc()..add(AddressListEvent(network: $store.net)),
      child: BlocBuilder<AddressBloc, AddressState>(builder: (context, state) {
        return CommonScaffold(
          title: 'addrBook'.tr,
          hasFooter: false,
          grey: true,
          actions: [
            GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.add_circle_outline),
              ),
              onTap: () {
                Get.toNamed(addressAddPage);
              },
            )
          ],
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 40),
            child: Column(
              children: [
                Padding(
                  child: NetEntranceWidget(
                      onChange: (net) =>
                      {
                        onChanges(context, net)}),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                ),
                Column(
                  children: List.generate(state.list.length, (index) {
                    var addr = state.list[index];
                    return SwiperWidget(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText.white(addr.label),
                          SizedBox(
                            height: 5,
                          ),
                          CommonText.white(
                              dotString(str: addr.address), size: 12)
                        ],
                      ),
                      onDelete: () {
                        showDeleteDialog(context,
                            title: 'deleteAddr'.tr,
                            content: 'confirmDelete'.tr, onDelete: () {
                              BlocProvider.of<AddressBloc>(context)
                                ..add(
                                    DeleteListEvent(addr: addr, index: index));
                              showCustomToast('deleteSucc'.tr);
                            });
                      },
                      onTap: () {
                        copyText(addr.address);
                        showCustomToast('copyAddr'.tr);
                      },
                      onSet: () {
                        Get.toNamed(addressAddPage,
                            arguments: {'mode': 1, 'addr': addr});
                      },
                    );
                  }),
                )
              ],
            ),
          ),
        );
      }),);
  }
}

class NetEntranceWidget extends StatelessWidget {
  final SingleParamCallback<Network> onChange;
  final Network network;
  NetEntranceWidget({this.onChange,this.network});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressBloc, AddressState>(builder: (context,state){
      return GestureDetector(
        onTap: () {
          Get.toNamed(addressNetPage).then((value) {
            if (value is Network) {
              onChange(value);
            }
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
              borderRadius: CustomRadius.b6,
              border: Border.all(
                color: Colors.grey[200],
              )),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: CustomColor.primary,
                    borderRadius: BorderRadius.circular(15)),
                child: Image(
                  image: AssetImage('icons/fil-w.png'),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Layout.colStart([
                CommonText(state.net == null ? "" : state.net.label),
                CommonText.grey(
                  'showCurrentAddr'.tr,
                  size: 12,
                )
              ]),
              Spacer(),
              Image(
                width: 20,
                image: AssetImage('icons/right.png'),
              )
            ],
          ),
        ),
      );
    });
  }
}
