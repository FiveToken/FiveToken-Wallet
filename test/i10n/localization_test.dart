import 'package:fil/i10n/localization.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  int dateTime = 1639389988079;
  test("generate config ChineseCupertinoLocalizations", () async {
    ChineseCupertinoLocalizations local = ChineseCupertinoLocalizations();
    local.init();
    var hour = local.datePickerHour(15);
    var month= local.datePickerDayOfMonth(dateTime);
    print(hour);
    print(month);
  });
}