import 'package:fil/index.dart';

class ConectedWallet extends StatelessWidget {
  final WCMeta meta;
  final Noop onConnect;
  final Noop onCancel;
  final Widget footer;
  ConectedWallet({this.meta, this.onCancel, this.onConnect, this.footer});
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 800),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 100,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Image.network(
                meta.icons[0],
                errorBuilder: (BuildContext context, Object object,
                    StackTrace stackTrace) {
                  return Image(
                    image: AssetImage('icons/wc-blue.png'),
                  );
                },
              ),
            ),
            CommonText(
              meta.name,
              size: 16,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CommonText('Connect to this dapp'),
            ),
            footer ??
                Container(
                  child: Row(
                    children: [
                      Expanded(
                          child: FButton(
                        text: 'Connect',
                        alignment: Alignment.center,
                        onPressed: () {
                          Get.back();
                          onConnect();
                        },
                        height: 40,
                        style: TextStyle(color: Colors.white),
                        color: CustomColor.primary,
                        corner: FCorner.all(6),
                      )),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          child: FButton(
                        alignment: Alignment.center,
                        height: 40,
                        onPressed: () {
                          Get.back();
                          onCancel();
                        },
                        style: TextStyle(color: Colors.white),
                        corner: FCorner.all(6),
                        color: Colors.red,
                        text: 'Cancel',
                      ))
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  margin: EdgeInsets.only(bottom: 20),
                )
          ],
        ),
      ),
    );
  }
}
