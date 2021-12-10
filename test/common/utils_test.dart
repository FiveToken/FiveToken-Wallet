import 'package:fil/chain/net.dart';
import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constant.dart';

void main() {
  final raw = FilPrivate;
  group("test aes", () {
    var encryptStr =
        'hp2iyoU5O4kODbx3QBo4RT2Y++7Ix5MIZeHrdQbhLJ1p9vOIv4CZB2rJsWUHNJqN';
    test("aes encrypt", () {
      var res = aesEncrypt(raw, raw);
      expect(res, encryptStr);
    });
    test("aes decrypt", () {
      var res = aesDecrypt(encryptStr, raw);
      expect(res, raw);
    });
  });
  test("generate hash", () {
    var res = tokenify(raw);
    var hash = 'a4e24708494a335e1c76d237059f069b58e8e715';
    expect(res, hash);
  });
  test('dot string', () {
    var addr =
        'f3ru7s7lajvcdcagztyz6qfo5qnlu6h6xzazg4eqwfyyexff36tkeg2ce2raidffniq222qpr2rvtfjwvwikaa';
    var dotStr = 'f3ru7s...vwikaa';
    var res = dotString(str: addr);
    expect(res, dotStr);
  });
  test('check  input is a valid decimal ', () {
    var numStr = '1.23';
    var wrongStr = '1..23';
    var wrongStr2 = '1..23e';
    expect(isDecimal(numStr), true);
    expect(isDecimal(wrongStr), false);
    expect(isDecimal(wrongStr2), false);
  });
  group("check address is valid", () {
    var eth = '0xEa00C8d2d4e658Afc23737181aa1c12F9b99551e';
    var fil1 = 'f14xxtyp7negvl3rvacc67povupv3tsu4b2ngjepq';
    var fil3 =
        'f3ru7s7lajvcdcagztyz6qfo5qnlu6h6xzazg4eqwfyyexff36tkeg2ce2raidffniq222qpr2rvtfjwvwikaa';
    var fil0 = 'f01220';
    var contract = "0xdd42bcecbe746e8f9415138ef01a4d16d1553df8";
    var filNet = Network.filecoinMainNet;
    var ethNet = Network.ethMainNet;
    test('check contract addr', () {
      expect(isValidContractAddress(contract), true);
    });
    test('check addr by net', () async {
      var vaild = await isValidChainAddress(fil1, filNet);
      expect(vaild, true);
      expect(isValidChainAddress(eth, ethNet), true);
      expect(isValidChainAddress(eth, filNet), false);
    });
  });
  test('generate private key by mne', () {
    var pk = genCKBase64(Mne);
    expect(pk, raw);
  });

  test('copyText', () {
    var str = "";
    fun(){
      str = 'abcdefg';
    }
    copyText(str, callback:fun );
    expect(str, 'abcdefg');
  });

  test('format coin', () {
    var amount = '1236000000000000000';
    var format =
        formatCoin(amount, size: 2);
    var formatFixed =
        formatCoin(amount, size: 2,min: 0.00000000001);
    expect(format, '1.23 FIL');
    expect(formatFixed, '0.00000000...');
  });
  test('convart a double string to  valid value in chain', () {
    var str = '1.23';
    var res = getChainValue(str);
    expect(res, '1230000000000000000');
  });
  test('format double', () {
    var str = '1.236';
    expect(formatDouble(str, size: 2, truncate: true), '1.23');
    expect(formatDouble(str, size: 2, truncate: false), '1.236');
  });

  test('Valid Password',(){
    var password = '1234567890';
    expect(isValidPass(password),false);
  });

  test('convert base64 to hex', () {
    var res = base64ToHex(raw, '1');
    var hex =
        '7b2254797065223a22736563703235366b31222c22507269766174654b6579223a22413066553636356f5a67514d46656b5144434c31686872456b76464e445955766a39336d4c5565703079493d227d';
    expect(res, hex);
  });
  test('check password', () {
    var pass = 'Aa123456';
    var wrongPass = 'Aa12345';
    var wrongPass2 = 'a1234567';
    var wrongPass3 = '12345678';
    var wrongPass4 = 'Aabcdefg';
    expect(isValidPassword(pass), true);
    expect(isValidPassword(wrongPass), false);
    expect(isValidPassword(wrongPass2), false);
    expect(isValidPassword(wrongPass3), false);
    expect(isValidPassword(wrongPass4), false);
  });
  test('check url', () {
    var url = 'http://www.filecoin.io';
    var wrongUrl = 'http://www.filecoin.';
    expect(isValidUrl(url), true);
    expect(isValidUrl(wrongUrl), false);
  });
  test('get valid wallet conect url', () {
    var wc =
        'wc:d44faf32-6a72-43d4-a193-6525f50a9d10@1?bridge=https%3A%2F%2Fh.bridge.walletconnect.org&key=4ab952e5a7c8e37bcdbdbd8aafdd422b5d96fb139ecf0da2a4835386c2a7dea7';
    var wrongWc =
        'wc:d44faf32-6a72-43d4-a193-6525f50a9d10@1?bridge=https%3A%2F%2Fh.bridge.walletconnect.org';
    var filWc = 'filecoinwallet:uri=d44faf32-6a72-43d4-a193';
    expect(getValidWCLink(wc), wc);
    expect(getValidWCLink(wrongWc), 'd44faf32-6a72-43d4-a193');
    expect(getValidWCLink(filWc), wc);
  });

  test('string trim',(){
    var str = '  abcsdefg    ';
    expect(StringTrim(str),'abcsdefg');
  });

  test('format string with params', () {
    var str = 'hello @to';
    expect(trParams(str, {'to': 'world'}), 'hello world');
    expect(
        trParams(
          str,
        ),
        str);
  });
}
