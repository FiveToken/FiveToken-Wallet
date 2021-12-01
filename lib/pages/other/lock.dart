import 'package:fil/index.dart';
import 'package:flutter/material.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:passcode_screen/circle.dart';//如需要自定义密码圆点UI时需引入
import 'package:passcode_screen/keyboard.dart';//如需要自定义键盘UI时需引入

class LockPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LockPageState();
  }
}

class LockPageState extends State<LockPage> {
  bool flag = false;
  @override
  var _context;
  int count = 0;
  Widget build(BuildContext context) {
    _context = context;
    return CommonScaffold(
        title: 'lockScreenSetting'.tr,
        hasFooter: false,
        grey: true,
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Column(
              children: [
                _switch(),
                SizedBox(
                  height: 15,
                ),
                Visibility(
                  visible: flag,
                  child: _editAction(),
                )
              ],
            )
        )
    );
  }

  Widget _switch(){
    return Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText.main('lockScreen'.tr),
            Switch(value: flag, onChanged: (value){
              onSwitchChanged(value);
            }),
          ],
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: CustomRadius.b8
        )
    );
  }
  
  Widget _editAction(){
    return Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText.main('lockScreenPassword'.tr),
            Row(
              children:[ CardItem(
                label: 'change'.tr,
                onTap: ()=>{
                  openLockScreen(_context)
                },
              ),
              ]
            )
          ],
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            // border: new Border.all(width: 1, color: Colors.grey),
            borderRadius: CustomRadius.b8
        )
    );
  }
  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();
  final StreamController<bool> _verificationNotifier2 = StreamController<bool>.broadcast();
  bool secondFlag = true;
  @override
  void dispose() {
    _verificationNotifier.close();
    _verificationNotifier2.close();
    super.dispose();
  }

  void passwordEnteredCallback(String enterPassCode){
    bool isValid = '123456' == enterPassCode;
    _verificationNotifier.add(isValid);
    openLockSencondScreen(_context);
  }

  Widget title(label){
    return Text(label,style: TextStyle(color: Colors.white));
  }

  void openLockScreen(context){
    Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation){
      return PasscodeScreen(
          title: title('cancel'.tr),
          passwordEnteredCallback: passwordEnteredCallback,
          cancelButton: title('cancel'.tr),
          deleteButton: title('delete'.tr),
          shouldTriggerVerification: _verificationNotifier.stream,
      );
    }));
  }

  void passwordEnteredCallback2(String enterPassCode){
    print(enterPassCode);
    bool isValid = '123456' == enterPassCode;
    _verificationNotifier2.add(isValid);
  }

  void openLockSencondScreen(context){
    Navigator.pop(context);
    Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation){
      return PasscodeScreen(
        title: title('delete'.tr),
        passwordEnteredCallback: passwordEnteredCallback2,
        cancelButton: title('cancel'.tr),
        deleteButton: title('delete'.tr),
        shouldTriggerVerification: _verificationNotifier2.stream,
      );
    }));
  }

  onSwitchChanged(value){
     setState(() {
       this.flag = value;
     });
     if(this.flag){
       openLockScreen(_context);
     }
  }

}
