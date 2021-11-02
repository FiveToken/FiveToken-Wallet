import 'package:fil/index.dart';

Row _getRowByAlign(MainAxisAlignment align, List<Widget> children) {
  return Row(
    children: children,
    mainAxisAlignment: align,
  );
}

Column _getColByAlign(CrossAxisAlignment align, List<Widget> children) {
  return Column(
    children: children,
    crossAxisAlignment: align,
  );
}

class Layout {
  static Row rowStart(List<Widget> children) =>
      _getRowByAlign(MainAxisAlignment.start, children);
  static Row rowCenter(List<Widget> children) =>
      _getRowByAlign(MainAxisAlignment.center, children);
  static Row rowEnd(List<Widget> children) =>
      _getRowByAlign(MainAxisAlignment.end, children);
  static Row rowBetween(List<Widget> children) =>
      _getRowByAlign(MainAxisAlignment.spaceBetween, children);
  static Column colStart(List<Widget> children) =>
      _getColByAlign(CrossAxisAlignment.start, children);
  static Column colCenter(List<Widget> children) =>
      _getColByAlign(CrossAxisAlignment.center, children);
  static Column colEnd(List<Widget> children) =>
      _getColByAlign(CrossAxisAlignment.end, children);
}
