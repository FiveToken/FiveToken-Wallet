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
