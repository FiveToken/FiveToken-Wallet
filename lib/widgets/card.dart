import 'package:fil/index.dart';

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
        padding: EdgeInsets.symmetric(
          horizontal: 12
        ),
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
