import 'package:fil/bloc/lock/lock_bloc.dart';
import 'package:fil/bloc/select/select_bloc.dart';
import 'package:fil/chain/lock.dart';
import 'package:fil/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  var _context;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    _context = context;
    return BlocBuilder<LockBloc, LockState>(builder: (context, state){
      return CommonScaffold(
            title: 'lockScreenSetting'.tr,
            hasFooter: false,
            grey: true,
            body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                child: Column(
                  children: [
                    _switch(context, state),
                    SizedBox(
                      height: 15,
                    ),
                    Visibility(
                      visible: state.lock,
                      child: _editAction(context, state),
                    )
                  ],
                )
            )
      );
    });
  }

  Widget _switch(context, state){
    return Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText.main('lockScreen'.tr),
            Switch(value: state.lock, onChanged: (value){
              onSwitchChanged(context,state, value);
            }),
          ],
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: CustomRadius.b8
        )
    );
  }
  
  Widget _editAction(context, state){
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
                  openLockScreen(context, state)
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
  @override
  void dispose() {
    _verificationNotifier.close();
    _verificationNotifier2.close();
    super.dispose();
  }

  void passwordEnteredCallback(context, state, String enterPassCode){
    bool isValid = true;
    _verificationNotifier.add(isValid);
    openLockSencondScreen(context, state, enterPassCode);
  }

  Widget title(label){
    return Text(label,style: TextStyle(color: Colors.white));
  }

  void openLockScreen(context, state){
    Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation){
      return PasscodeScreen(
          title: title('setLockPassword'.tr),
          passwordEnteredCallback: (String pass)=>{ passwordEnteredCallback(context, state,pass)},
          cancelButton: title('cancel'.tr),
          deleteButton: title('delete'.tr),
          shouldTriggerVerification: _verificationNotifier.stream,
      );
    }));
  }

  void passwordEnteredCallback2(String secondPass, String firstPass){
    bool isValid = secondPass == firstPass;
    var lockBox = OpenedBox.lockInstance;
    LockBox lock = LockBox.fromJson({'lockscreen': true, 'password':secondPass});
    lockBox.put('lock', lock);
    BlocProvider.of<LockBloc>(context).add(setLockEvent(password: secondPass, lock: true));
    _verificationNotifier2.add(isValid);
  }

  void openLockSencondScreen(context, state, String firstPass){
    Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation){
      return PasscodeScreen(
        title: title('confirmLockPassword'.tr),
        passwordEnteredCallback: (value)=>{passwordEnteredCallback2(value, firstPass)},
        cancelButton: title('cancel'.tr),
        deleteButton: title('delete'.tr),
        shouldTriggerVerification: _verificationNotifier2.stream,
      );
    }));
  }

  onSwitchChanged(ctx,  state, value){
    BlocProvider.of<LockBloc>(context).add(setLockEvent(lock: value));
     if(value){
       openLockScreen(ctx, state);
     }
  }
}
