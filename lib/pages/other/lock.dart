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
      return BlocListener<LockBloc, LockState>(
        listener: (context, state){
          print(state);
        },
        child: CommonScaffold(
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
        ),
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
                  BlocProvider.of<LockBloc>(context).add(SetLockEvent(status: 'update',lock: state.lock, password: state.password)),
                  openLockScreen(context, state, 'update')
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

  void passwordEnteredCallback(ctx, state, String enterPassCode, String status) {
    bool isValid = true;
    _verificationNotifier.add(isValid);
    // Navigator.pop(ctx);
    Future.delayed(Duration.zero).then((value) =>openLockSencondScreen(ctx, state, enterPassCode, status));
  }

  Widget title(label){
    return Text(label,style: TextStyle(color: Colors.white));
  }

  Widget cancel(label, state, status){
    if(status=='create'){
      BlocProvider.of<LockBloc>(context).add(SetLockEvent(lock: false));
    }
    return FButton(text: label, onPressed: ()=>{
     _verificationNotifier.add(true),
    _verificationNotifier2.add(true)

    });
  }

  void openLockScreen(ctx, state, status) {
    Navigator.push(ctx,
        PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) {
          return PasscodeScreen(
            title: title('setLockPassword'.tr),
            passwordEnteredCallback: (String pass) =>
            {passwordEnteredCallback(ctx, state, pass, status)},
            cancelButton: cancel('cancel'.tr, state, status),
            deleteButton: title('delete'.tr),
            shouldTriggerVerification: _verificationNotifier.stream,
            isValidCallback: () {},
          );
        }));
  }

  void passwordEnteredCallback2(String secondPass, String firstPass){
    bool isValid = secondPass == firstPass;
    _verificationNotifier2.add(isValid);
    var lockBox = OpenedBox.lockInstance;
    LockBox lock = LockBox.fromJson({'lockscreen': true, 'password':secondPass});
    lockBox.put('lock', lock);
    BlocProvider.of<LockBloc>(context).add(SetLockEvent(password: secondPass, lock: true));
  }

  void openLockSencondScreen(context, state, String firstPass, String status){
    Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation){
      return PasscodeScreen(
        isValidCallback: () {},
        title: title('confirmLockPassword'.tr),
        passwordEnteredCallback: (value)=>{passwordEnteredCallback2(value, firstPass)},
        cancelButton: cancel('cancel'.tr, state, status),
        deleteButton: title('delete'.tr),
        shouldTriggerVerification: _verificationNotifier2.stream,
      );
    }));
  }

  onSwitchChanged(ctx,  state, value){
    BlocProvider.of<LockBloc>(context).add(SetLockEvent(lock: value, status: 'create'));
     if(value){
       openLockScreen(ctx, state, 'create');
     }
  }
}
