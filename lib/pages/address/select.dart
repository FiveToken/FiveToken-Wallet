import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';
/// select a address when transfer 
class AddressBookSelectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddressBookSelectPageState();
  }
}

class AddressBookSelectPageState extends State<AddressBookSelectPage> {
  var box = OpenedBox.addressBookInsance;
  List<ContactAddress> list = [];
  void setList() {
    setState(() {
      list = box.values.where((addr) => addr.rpc == $store.net.rpc).toList();
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
        title: 'selectAddr'.tr,
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
          padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
          child: Layout.colStart([
            CommonText($store.net.label),
            SizedBox(
              height: 12,
            ),
            TapCardWidget(
              Layout.rowBetween([
                CommonText.white('selectWalletAddr'.tr),
                Image(width: 18, image: AssetImage('icons/right-w.png'))
              ]),
              onTap: () {
                Get.toNamed(addressWalletPage).then((value){
                  if(value is ChainWallet){
                    Get.back(result: value);
                  }
                });
              },
            ),
            SizedBox(
              height: 12,
            ),
            Column(
              children: List.generate(
                list.length,
                (index) {
                  var wallet = list[index];
                  return Column(
                    children: [
                      GestureDetector(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText.white(wallet.label, size: 15),
                              SizedBox(
                                height: 5,
                              ),
                              CommonText.white(
                                dotString(str: wallet.address),
                                size: 10,
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            borderRadius: CustomRadius.b8,
                            color: CustomColor.primary,
                          ),
                        ),
                        onTap: () {
                          Get.back(result: wallet);
                        },
                      ),
                      SizedBox(
                        height: 8,
                      )
                    ],
                  );
                },
              ),
            )
          ]),
        ));
  }
}
