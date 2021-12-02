

import 'package:passcode_screen/passcode_screen.dart';

import '../../index.dart';

class ScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LockScreenPage();
  }
}

class LockScreenPage extends State<ScreenPage> {

  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();
  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }

  void passwordEnteredCallback(String enterPassCode){
    bool isValid = enterPassCode == '12345678';
    _verificationNotifier.add(isValid);
  }

  Widget title(label){
    return Text(label,style: TextStyle(color: Colors.white));
  }

  Widget build(BuildContext context) {
    return  PasscodeScreen(
      title: title('setLockPassword'.tr),
      passwordEnteredCallback: passwordEnteredCallback,
      cancelButton: title('cancel'.tr),
      deleteButton: title('delete'.tr),
      shouldTriggerVerification: _verificationNotifier.stream,
    );
  }
}