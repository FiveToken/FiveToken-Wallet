import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/models/wallet.dart';
void main() {
  test("generate model wallet", () async {
     Nonce nonce =Nonce.fromJson({
       'time': 1639287942265,
       'value': 1234567890
     });
     Nonce nonce1 = Nonce(time: 1639288444578,value: 11111111111);
     nonce1.toString();
     nonce1.toJson();
     expect(nonce.value, 1234567890);
     expect(nonce1.value, 11111111111);
  });
  test("generate model gas", () async {
    CacheGas gas = CacheGas(
      feeCap: '12',
      premium: '1',
      cid: 'IW1poEdzBuTz0jjeYCL4XB9M',
    );
    expect(gas.cid, 'IW1poEdzBuTz0jjeYCL4XB9M');
  });
}