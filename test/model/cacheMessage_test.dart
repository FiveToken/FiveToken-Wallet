import 'package:fil/chain/token.dart' show Token;
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/models/cacheMessage.dart';
void main() {
  Token token  = Token.fromJson({
    'symbol': 'FIL',
    'precision': 0,
    'address': 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
    'chain': 'eth',
    'rpc': 'https://api.fivetoken.io',
    'balance':'100000000000000'
  });
  test("generate model cacheMessage", () async {
    CacheMessage msg1 = CacheMessage(
        from: 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
        to: 'f1k4effkl5cxd4bo5ec2ykuiyxgzwqwra527kp6ka',
        owner: 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
        hash: 'bafy2bzacecpq36akmsfnyxdbaiy4dp43no6g7nog2xh42s47vg7z3vhpk3ado',
        value: '100000000000000',
        blockTime: 1639012530,
        exitCode: 0,
        pending: 0,
        nonce: 552,
        rpc: 'https://api.fivetoken.io',
        token: token,
        gas: null,
        fee: '439799715206',
        height: 1356871,
        mid: '135687100189',
        symbol: 'FIL'
    );
    var value = msg1.formatValue;
    var resValue = '100000000000000FIL';
    expect(value, resValue);

  });
    test("generate model cacheMessage", () async {
      CacheMessage msg = CacheMessage(
          from: 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
          to: 'f1k4effkl5cxd4bo5ec2ykuiyxgzwqwra527kp6ka',
          owner: 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
          hash: 'bafy2bzacecpq36akmsfnyxdbaiy4dp43no6g7nog2xh42s47vg7z3vhpk3ado',
          value: '100000000000000',
          blockTime: 1639012530,
          exitCode: 0,
          pending: 0,
          nonce: 552,
          rpc: 'https://api.fivetoken.io',
          token: null,
          gas: null,
          fee: '439799715206',
          height: 1356871,
          mid: '135687100189',
          symbol: 'FIL'
      );
    var value = msg.formatValue;
    var resValue = '0.0001';
    expect(value, resValue);
  });
}