import 'package:flutter_test/flutter_test.dart';
import 'package:fil/models/address.dart';
void main() {
  test("generate model address", () async {
    ContactAddress address = ContactAddress(
      label: 'Ddd',
      address: '0xa45bc341e17e7bb8c3183644f6293e0a6d16071e',
      rpc: 'https://api.calibration.fivetoken.io',
    );
    String resKey = '0xa45bc341e17e7bb8c3183644f6293e0a6d16071e_https://api.calibration.fivetoken.io';
    expect(address.key, resKey);
  });
}