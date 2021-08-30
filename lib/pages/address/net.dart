import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';

class AddressBookNetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddressBookNetState();
  }
}

class AddressBookNetState extends State<AddressBookNetPage> {
  bool hideTest;
  List<List<Network>> get filterNets =>
      hideTest ? [Network.netList[0]] : Network.netList;
  @override
  void initState() {
    super.initState();
    hideTest = Global.store.getBool('hideTestnet') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'selectAddrNet'.tr,
      hasFooter: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12, 20, 12, 40),
        child: Column(
          children: [
            Layout.colStart(List.generate(filterNets.length, (index) {
              var nets = Network.netList[index];
              return Visibility(
                child: Layout.colStart([
                  CommonText(Network.labels[index]),
                  SizedBox(
                    height: 12,
                  ),
                  Layout.colStart(List.generate(nets.length, (index) {
                    var net = nets[index];
                    return Container(
                      child: TapCardWidget(
                        Container(
                          alignment: Alignment.centerLeft,
                          child: CommonText.white(net.label),
                        ),
                        onTap: () {
                          Get.back(result: net);
                        },
                      ),
                      margin: EdgeInsets.only(bottom: 12),
                    );
                  }))
                ]),
                visible: nets.isNotEmpty,
              );
            })),
            GestureDetector(
              onTap: () {
                setState(() {
                  hideTest = !hideTest;
                  Global.store.setBool('hideTestnet', hideTest);
                });
              },
              child: Container(
                child:
                    CommonText.grey(!hideTest ? 'hideTest'.tr : 'showTest'.tr),
              ),
            )
          ],
        ),
      ),
    );
  }
}
