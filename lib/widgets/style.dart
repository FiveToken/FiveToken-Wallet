import 'package:fil/index.dart';

const double NavHeight = 52;
const NavLeadingAlign = Alignment(-0.5, 0);

BorderRadius _getBorder(double radius) {
  return BorderRadius.all(Radius.circular(radius));
}

class CustomRadius {
  static BorderRadius get b2 {
    return _getBorder(6);
  }

  static BorderRadius get b4 {
    return _getBorder(6);
  }

  static BorderRadius get b6 {
    return _getBorder(6);
  }

  static BorderRadius get b8 {
    return _getBorder(8);
  }

  static BorderRadius get top {
    return BorderRadius.only(
        topLeft: Radius.circular(8), topRight: Radius.circular(8));
  }

  BorderRadius border(double radius) {
    return _getBorder(radius);
  }
}

class CustomColor {
  static Color get primary {
    return Color(0xff5CC1CB);
  }

  static Color get grey {
    return Color(0xffB4B5B7);
  }

  static Color get bgGrey {
    return Color(0xfff8f8f8);
  }

  static Color get red {
    return Color(0xffE85C5C);
  }
}
