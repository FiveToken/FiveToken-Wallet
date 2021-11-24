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
    return Column(
      children: [
        CommonText('锁定')
      ],
    );
  }
}
