import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/bloc/net/net_bloc.dart';
class NetIndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NetIndexStatePage();
  }
}

class NetIndexStatePage extends State<NetIndexPage> {

  void onPressed(BuildContext context){
    Get.toNamed(netAddPage).then((value) {
        BlocProvider.of<NetBloc>(context)..add(SetNetEvent(Network.netList));
    });
  }

  void onTap(BuildContext context, Network n){
    Get.toNamed(netAddPage, arguments: {'net': n})
        .then((value) {
          BlocProvider.of<NetBloc>(context)..add(SetNetEvent(Network.netList));
    });
  }

  @override
  void initState() {
    super.initState();

    debugPrint("text" + Network.netList.toString());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create:(context)=> NetBloc()..add(SetNetEvent(Network.netList)),
        child: BlocBuilder<NetBloc, NetState>(builder: (context, state){
              return CommonScaffold(
                title: 'net'.tr,
                footerText: 'add'.tr,
                onPressed: ()=>{ onPressed(context) },
                body: Column(
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(12, 20, 12, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(state.network.length, (index) {
                               var net = state.network[index];
                               var labels = Network.labels;
                               return net.length>0? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   CommonText(labels[index]),
                                   SizedBox(
                                     height: 12,
                                   ),
                                   Column(children: List.generate(net.length, (i){
                                     var n = net[i];
                                     bool custom = n.netType == 2;
                                     return GestureDetector(
                                       onTap: ()=>{onTap(context, n)},
                                       child: Container(
                                         height: 70,
                                         margin: EdgeInsets.only(bottom: 12),
                                         padding: EdgeInsets.all(12),
                                         decoration: BoxDecoration(
                                             color: CustomColor.primary,
                                             borderRadius: CustomRadius.b6),
                                             child: Row(
                                               mainAxisAlignment:
                                               MainAxisAlignment.spaceBetween,
                                               children: [
                                                 CommonText.white(
                                                   custom? n.name: n.label
                                                 ),
                                                 custom ? Transform.translate(
                                                   offset: Offset(0, 25),
                                                   child: Icon(
                                                     Icons.more_horiz_sharp,
                                                     color: Colors.white,
                                                     size: 16,
                                                   ),
                                                 ): Icon(
                                                   Icons.lock_outline,
                                                   color: Colors.white,
                                                   size: 16,
                                                 )
                                               ],
                                             ),
                                       )
                                     );
                                   }),)
                                 ],
                            ): Container();
                            }),
                          )
                        )
                    ),
                    SizedBox(
                      height: 120,
                    )
                  ],
                ),
              );
        })
    );
  }
}

