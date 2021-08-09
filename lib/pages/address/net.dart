import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';

class AddressBookNetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddressBookNetState();
  }
}

class AddressBookNetState extends State<AddressBookNetPage> {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '选择地址簿网络',
      hasFooter: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
        child: Column(
          children: List.generate(Network.netList.length, (index) {
            var nets = Network.netList[index];
            return Layout.colStart([
              CommonText(['主网', '测试网', '自定义网络'][index]),
              SizedBox(
                height: 12,
              ),
              Column(
                children: List.generate(nets.length, (index) {
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
                }),
              )
            ]);
          }),
        ),
      ),
    );
  }
}
