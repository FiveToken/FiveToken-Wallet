import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test precision limit formatter equal', () {
    var testOldValue = const TextEditingValue(text: '1.12345');
    var testNewValue = const TextEditingValue(text: '1.123456');
    final PrecisionLimitFormatter formatterUnderTest =
        PrecisionLimitFormatter(8);
    var newValue =
        formatterUnderTest.formatEditUpdate(testOldValue, testNewValue);
    expect(newValue, equals(testNewValue));
  });
  test('test precision limit formatter not equal', () {
    var testOldValue = const TextEditingValue(text: '1.12345678');
    var testNewValue = const TextEditingValue(text: '1.123456789');
    final PrecisionLimitFormatter formatterUnderTest =
        PrecisionLimitFormatter(8);
    var newValue =
        formatterUnderTest.formatEditUpdate(testOldValue, testNewValue);
    expect(newValue, isNot(equals(testNewValue)));
    expect(newValue, equals(testOldValue));
  });
}
