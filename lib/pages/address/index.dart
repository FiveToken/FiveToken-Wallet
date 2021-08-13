import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class AddressBookIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddressBookIndexPageState();
  }
}

class AddressBookIndexPageState extends State<AddressBookIndexPage> {
  var box = OpenedBox.addressBookInsance;
  Network net = $store.net;
  List<ContactAddress> list = [];

  void setList() {
    setState(() {
      list = box.values.where((addr) => addr.rpc == net.rpc).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    setList();
  }

  @override
  Widget build(BuildContext context) {
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
            Get.toNamed(addressAddPage).then((value) {
              setList();
            });
          },
        )
      ],
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, 20, 0, 40),
        child: Column(
          children: [
            Padding(
              child: NetEntranceWidget(
                net: net,
                onChange: (net) {
                  setState(() {
                    this.net = net;
                    list = box.values
                        .where((addr) => addr.rpc == net.rpc)
                        .toList();
                  });
                },
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
            Column(
              children: List.generate(list.length, (index) {
                var addr = list[index];
                return SwiperWidget(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText.white(addr.label),
                      SizedBox(
                        height: 5,
                      ),
                      CommonText.white(dotString(str: addr.address), size: 12)
                    ],
                  ),
                  onDelete: () {
                    showDeleteDialog(context,
                        title: 'deleteAddr'.tr,
                        content: 'confirmDelete'.tr, onDelete: () {
                      box.delete(addr.key);
                      list.removeAt(index);
                      setList();
                      showCustomToast('deleteSucc'.tr);
                    });
                  },
                  onTap: () {
                    copyText(addr.address);
                    showCustomToast('copyAddr'.tr);
                  },
                  onSet: () {
                    Get.toNamed(addressAddPage,
                        arguments: {'mode': 1, 'addr': addr}).then((value) {
                      setList();
                    });
                  },
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}

Widget _getIconButton(Color color, Widget icon) {
  return Container(
    width: 50,
    height: 50,
    padding: EdgeInsets.all(12),
    margin: EdgeInsets.only(top: 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      color: color,
    ),
    child: icon,
  );
}

class SwiperItem extends StatelessWidget {
  final Wallet wallet;
  final Noop onDelete;
  final Noop onSet;
  final Noop onTap;
  final bool showBalance;
  SwiperItem(
      {this.onDelete,
      this.onSet,
      this.wallet,
      this.onTap,
      this.showBalance = false});
  @override
  Widget build(BuildContext context) {
    return SwipeActionCell(
      key: ValueKey(wallet.addr),
      trailingActions: [
        SwipeAction(
            color: Colors.transparent,
            content: _getIconButton(
                CustomColor.red,
                Image(
                  image: AssetImage('icons/delete.png'),
                )),
            onTap: (handler) async {
              handler(false);
              onDelete();
            }),
        SwipeAction(
            content: _getIconButton(
                Color(0xffE8CC5C),
                Image(
                  image: AssetImage('icons/set.png'),
                )),
            color: Colors.transparent,
            onTap: (handler) {
              handler(false);
              onSet();
            }),
      ],
      child: Padding(
        padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: GestureDetector(
          child: Container(
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CommonText.white(wallet.label, size: 16),
                    Visibility(
                      child: CommonText.white(
                          formatDouble(wallet.balance,
                                  truncate: true, size: 4) +
                              ' Fil',
                          size: 16),
                      visible: showBalance,
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                CommonText.white(
                  dotString(str: wallet.address),
                  size: 12,
                ),
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: CustomRadius.b8,
                color: wallet.address == $store.wal.address
                    ? CustomColor.primary
                    : Color(0xff8297B0)),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class NetEntranceWidget extends StatelessWidget {
  final SingleParamCallback<Network> onChange;
  final Network net;
  NetEntranceWidget({this.onChange, this.net});
  @override
  Widget build(BuildContext context) {
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
              CommonText(net.label),
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
  }
}
