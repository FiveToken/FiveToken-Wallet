import 'package:fil/index.dart';
import 'package:random_color/random_color.dart';

class RandomIcon extends StatelessWidget {
  final String address;
  final double size;
  RandomIcon(this.address, {this.size = 30});
  String get numStr {
    return address.substring(2);
  }

  double get rate => size / 30;

  List<List<double>> get transforms {
    var radixNum = BigInt.parse(numStr, radix: 16).toString();
    var num1 = radixNum.substring(0, 8);
    var num2 = radixNum.substring(8, 16);
    var num3 = radixNum.substring(16, 24);
    return [getTransform(num1), getTransform(num2), getTransform(num3)];
  }

  List<double> getTransform(String str) {
    var xDir = int.parse(str[0]) % 2 == 0 ? 1 : -1;
    var yDir = int.parse(str[1]) % 2 == 0 ? 1 : -1;
    var angle = str.substring(2, 4);
    var dx = str.substring(4, 6);
    var dy = str.substring(6, 8);
    return [
      rate * xDir * max(int.parse(dx) / 8, 7.5),
      rate * yDir * max(int.parse(dy) / 8, 7.5),
      xDir * yDir * pi * int.parse(angle) / 180,
    ];
  }

  List<Color> get colors {
    var seed = int.parse(numStr.substring(0, 10), radix: 16);
    var ramdom = RandomColor(seed);
    var list = [
      ramdom.randomColor(),
      ramdom.randomColor(),
      ramdom.randomColor()
    ];
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: CustomColor.primary,
          borderRadius: BorderRadius.all(Radius.circular(size / 2))),
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(colors.length, (index) {
          var trans = transforms[index];
          return Positioned(
              left: trans[0],
              top: trans[1],
              child: Transform.rotate(
                angle: trans[2],
                child: Container(
                  width: size,
                  height: size,
                  color: colors[index],
                ),
              ));
        }),
      ),
    );
  }
}
