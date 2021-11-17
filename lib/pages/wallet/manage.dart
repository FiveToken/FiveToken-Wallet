import 'package:fil/bloc/select/select_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
// import 'package:fil/index.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/widgets/index.dart';
import 'package:fil/store/store.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/widgets/style.dart';

class WalletManagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletManagePageState();
  }
}

class WalletManagePageState extends State<WalletManagePage> {
  ChainWallet wallet = Get.arguments['wallet'];
  Network net = Get.arguments['net'];
  TextEditingController controller = TextEditingController();

  bool get isId {
    return wallet.type == 0;
  }

  String get addr {
    return wallet.addr;
  }

  CardItem _nameItem(BuildContext context) {
    return CardItem(
      label: isId ? 'idName'.tr : 'walletName'.tr,
      onTap: () {
        controller.text = wallet.label;
        var hash = wallet.groupHash;

        showCustomDialog(
            context,
            Container(
              child: Column(
                children: [
                  CommonTitle(
                    'changeWalletName'.tr,
                    showDelete: true,
                  ),
                  Padding(
                    child: Field(
                      autofocus: true,
                      controller: controller,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  ),
                  Divider(
                    height: 1,
                  ),
                  Container(
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            child: CommonText(
                              'cancel'.tr,
                            ),
                            alignment: Alignment.center,
                          ),
                          onTap: () {
                            Get.back();
                          },
                        )),
                        Container(
                          width: .2,
                          color: CustomColor.grey,
                        ),
                        Expanded(
                            child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            child: CommonText(
                              'sure'.tr,
                              color: CustomColor.primary,
                            ),
                            alignment: Alignment.center,
                          ),
                          onTap: () {
                            var newLabel = controller.text.trim();
                            if (newLabel == '') {
                              showCustomError('enterName'.tr);
                              return;
                            }
                            if (newLabel.length > 20) {
                              showCustomError('nameTooLong'.tr);
                              return;
                            }
                            wallet.label = newLabel;
                            if (wallet.type == 0) {
                              if (wallet.groupHash == $store.wal.groupHash) {
                                $store.changeWalletName(newLabel);
                              }
                            } else {
                              if (wallet.key == $store.wal.key) {
                                $store.changeWalletName(newLabel);
                              }
                            }

                            // List<ChainWallet> list = [];
                            // if (wallet.type != 2) {
                            //   list = OpenedBox.walletInstance.values
                            //       .where((wal) => wal.groupHash == hash)
                            //       .toList();
                            // } else {
                            //   list = [wallet];
                            // }
                            // list.forEach((wal) {
                            //   wal.label = newLabel;
                            //   OpenedBox.walletInstance.put(wal.key, wal);
                            // });
                            // setState(() {});
                            BlocProvider.of<SelectBloc>(context)
                              ..add(WalletDeleteEvent(
                                  wallet: wallet, newLabel: newLabel));
                            Get.back();
                            showCustomToast('changeNameSucc'.tr);
                          },
                        )),
                      ],
                    ),
                  )
                ],
              ),
            ),
            color: CustomColor.bgGrey);
      },
      append: BlocBuilder<SelectBloc, SelectState>(
        builder: (context, state) {
          return Row(
            children: [
              Container(
                width: 150,
                alignment: Alignment.centerRight,
                child: SingleChildScrollView(
                  child: CommonText(
                    state.label,
                    align: TextAlign.right,
                  ),
                  scrollDirection: Axis.horizontal,
                ),
              ),
              ImageAr
            ],
          );
        },
      ),
    );
  }

  TapItemCard get exportCard {
    List<CardItem> list = [
      CardItem(
          label: 'pkExport'.tr,
          onTap: () {
            showPassDialog(context, (String pass) async {
              var private = await wallet.getPrivateKey(pass);
              Get.toNamed(walletPrivatekey,
                  arguments: {'private': private, 'wallet': wallet});
            }, wallet: wallet);
          }),
      CardItem(
          label: 'mneExport'.tr,
          onTap: () {
            showPassDialog(context, (String pass) async {
              try {
                var ck = await wallet.getPrivateKey(pass);
                var mne = aesDecrypt(wallet.mne, ck);
                Get.toNamed(walletMnePage, arguments: {'mne': mne});
              } catch (e) {
                showCustomError(e.toString());
                print(e);
              }
            }, wallet: wallet);
          }),
    ];
    if (wallet.type == 2) {
      list.removeAt(1);
    }
    return TapItemCard(
      items: list,
    );
  }

  CardItem get addrItem {
    return CardItem(
      label: 'walletAddr'.tr,
      append: CommonText(
        dotString(str: addr),
      ),
    );
  }

  CardItem get passItem {
    return CardItem(
      label: isId ? 'changeIdPass'.tr : 'changePass'.tr,
      onTap: () {
        Get.toNamed(passwordResetPage, arguments: {'wallet': wallet});
      },
    );
  }

  // Id manage
  Widget _idChild(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        TapItemCard(items: [_nameItem(context), passItem]),
        SizedBox(
          height: 15,
        ),
        TapItemCard(
          items: [
            CardItem(
              label: 'walletAddr'.tr,
              onTap: () {},
              append: CommonText(
                dotString(str: addr),
              ),
            )
          ],
        ),
        SizedBox(
          height: 15,
        ),
        exportCard
      ],
    );
  }

  // wallet manage
  Widget _walletChild(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        TapItemCard(
          items: [
            addrItem,
            _nameItem(context),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        exportCard,
        SizedBox(
          height: 15,
        ),
        TapItemCard(
          items: [passItem],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectBloc()..add(WalletDeleteEvent())..add(LabelEvent(wallet.label)),
      child: CommonScaffold(
        title: 'manageWallet'.tr,
        grey: true,
        hasFooter: false,
        body: BlocBuilder<SelectBloc, SelectState>(
          builder: (context, state) {
            return Padding(
              child: isId ? _idChild(context) : _walletChild(context),
              padding: EdgeInsets.symmetric(horizontal: 12),
            );
          },
        ),
      ),
    );
  }
}
