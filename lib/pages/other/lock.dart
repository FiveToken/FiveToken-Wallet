import 'package:fil/index.dart';
import 'package:flutter/material.dart';

class LockPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LockPageState();
  }
}

class LockPageState extends State<LockPage> {

  @override
  Widget build(BuildContext context) {
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
                _editAction()
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
            Switch(value: false, onChanged: (value){
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
              children: [
                CommonText.main('change'.tr)
              ],
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


  onSwitchChanged(value){

  }
}
