import 'package:fil/widgets/style.dart' show CustomColor, CustomRadius;
import 'package:flutter/material.dart';
import 'package:fil/models/index.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/index.dart';

class CommonCard extends StatelessWidget {
  final Widget child;
  CommonCard(this.child);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
    );
  }
}

class TapCardWidget extends StatelessWidget {
  final Widget child;
  final Color color;
  final Noop onTap;
  TapCardWidget(this.child, {this.color, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        width: double.infinity,
        height: 70,
        child: child,
        decoration: BoxDecoration(
            color: color ?? CustomColor.primary, borderRadius: CustomRadius.b6),
      ),
      onTap: () {
        if (this.onTap != null) {
          onTap();
        }
      },
    );
  }
}

class TapItemCard extends StatelessWidget {
  final List<CardItem> items;
  TapItemCard({this.items});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(7)),
      child: Column(
        children: List.generate(items.length, (index) {
          return Container(
            child: Column(
              children: [
                items[index],
                Visibility(
                    child: Divider(
                      height: 1,
                    ),
                    visible: index != items.length - 1)
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 15),
          );
        }),
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  final String label;
  final Noop onTap;
  final Widget append;
  CardItem({@required this.label, this.onTap, this.append});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText.main(label),
            SizedBox(
              width: 20,
            ),
            append ?? ImageAr
          ],
        ),
        height: 40,
      ),
      onTap: onTap,
    );
  }
}
