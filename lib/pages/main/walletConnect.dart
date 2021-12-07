// // import 'package:fil/index.dart';
// import 'package:fil/models/wc_meta.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:fbutton/fbutton.dart';
// import 'package:fil/models/index.dart';
// import 'package:fil/widgets/text.dart';
// import 'package:fil/widgets/style.dart';
//
// class ConnectWallet extends StatelessWidget {
//   final WcMeta meta;
//   final Noop onConnect;
//   final Noop onCancel;
//   final Widget footer;
//   ConnectWallet({this.meta, this.onCancel, this.onConnect, this.footer});
//   @override
//   Widget build(BuildContext context) {
//     return ConstrainedBox(
//       constraints: BoxConstraints(maxHeight: 800),
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               width: 100,
//               padding: EdgeInsets.symmetric(vertical: 20),
//               child: Image.network(
//                 meta.icons[0],
//                 errorBuilder: (BuildContext context, Object object, StackTrace stackTrace) {
//                   return Image(
//                     image: AssetImage('icons/wc-blue.png'),
//                   );
//                 },
//               ),
//             ),
//             CommonText.center(meta.name, size: 16, color: Colors.black),
//             Container(
//               padding: EdgeInsets.symmetric(vertical: 20),
//               child: CommonText(meta.description),
//             ),
//             footer ??
//                 Container(
//                   child: Row(
//                     children: [
//                       Expanded(
//                           child: FButton(
//                         alignment: Alignment.center,
//                         height: 40,
//                         onPressed: () {
//                           Get.back();
//                           onCancel();
//                         },
//                         strokeWidth: .5,
//                         strokeColor: Color(0xffcccccc),
//                         //style: TextStyle(color: Colors.white),
//                         corner: FCorner.all(6),
//                         //color: Colors.red,
//                         text: 'cancel'.tr,
//                       )),
//                       SizedBox(
//                         width: 20,
//                       ),
//                       Expanded(
//                           child: FButton(
//                         text: 'connect'.tr,
//                         alignment: Alignment.center,
//                         onPressed: () {
//                           Get.back();
//                           onConnect();
//                         },
//                         height: 40,
//                         style: TextStyle(color: Colors.white),
//                         color: CustomColor.primary,
//                         corner: FCorner.all(6),
//                       )),
//                     ],
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 20),
//                   margin: EdgeInsets.only(bottom: 40),
//                 )
//           ],
//         ),
//       ),
//     );
//   }
// }
//
