import 'package:fil/index.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class AddressBookIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddressBookIndexPageState();
  }
}

class AddressBookIndexPageState extends State<AddressBookIndexPage> {
  var box = Hive.box<Wallet>(addressBookBox);
  List<Wallet> list = [];
  void setList() {
    setState(() {
      list = box.values.toList();
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
        child: Column(
          children: List.generate(list.length, (index) {
            var wallet = list[index];
            return SwiperItem(
              wallet: wallet,
              onDelete: () {
                showDeleteDialog(context,
                    title: 'deleteAddr'.tr,
                    content: 'confirmDelete'.tr, onDelete: () {
                  box.delete(wallet.addr);
                  list.removeAt(index);
                  setList();
                  showCustomToast('deleteSucc'.tr);
                });
              },
              onTap: () {
                copyText(wallet.address);
                showCustomToast('copyAddr'.tr);
              },
              onSet: () {
                Get.toNamed(addressAddPage,
                    arguments: {'mode': 1, 'wallet': wallet}).then((value) {
                  setList();
                });
              },
            );
          }),
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
    margin: EdgeInsets.only(
      top: 20
    ),
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
            padding: EdgeInsets.symmetric(horizontal: 12,vertical: 12),
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
                color:
                    wallet.addrWithNet == singleStoreController.wal.addrWithNet
                        ? CustomColor.primary
                        : Color(0xff8297B0)),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
