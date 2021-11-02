import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("test token", () {
    var token = Token(
        precision: 6,
        address: "0xEa00C8d2d4e658Afc23737181aa1c12F9b99551e",
        chain: "eth",
        symbol: 'ETH',
        balance: "10000000");
    expect(token.formatBalance, '10.0 ETH');
  });
}
