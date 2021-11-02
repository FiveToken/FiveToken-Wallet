import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constant.dart';

void main() {
  var topic = 'd44faf32-6a72-43d4-a193-6525f50a9d10';
  int version = 1;
  String bridgeUrl = 'https%3A%2F%2Fh.bridge.walletconnect.org';
  String keyHex =
      '4ab952e5a7c8e37bcdbdbd8aafdd422b5d96fb139ecf0da2a4835386c2a7dea7';
  test('test wallet connect meta', () {
    var map = {
      'name': WalletLabel,
      'description': 'awesome wallet',
      'url': 'https://www.fivetoken.io'
    };
    var meta = WCMeta.fromJson(map);
    expect(meta.name, map['name']);
  });
  test('test wc uri', () {
    var url = 'wc:$topic@$version?bridge=$bridgeUrl&key=$keyHex';
    var uri = WCUri.fromString(url);
    expect(uri.topic, topic);
    expect(uri.version, version);
    expect(uri.bridgeUrl, Uri.decodeComponent(bridgeUrl));
    expect(uri.keyHex, keyHex);
    expect(uri.toString(), url);
  });
  test('json rpc', () {
    var method = 'fivetoken';
    var id = 1;
    var data = {"data": 'awesome'};
    var map = {
      "id": id,
      "jsonrpc": "2.0",
      "method": method,
      "result": data,
      "params": null
    };

    var rpc = JsonRpc.fromJson(map);
    expect(rpc.method, method);
    expect(rpc.id, id);
    expect(rpc.result, equals(data));
    expect(
        rpc.toJson(),
        equals({
          "id": 1,
          "jsonrpc": "2.0",
          "method": "fivetoken",
          "params": null
        }));
  });
  test('test wc pub sub', () {
    var payload = 'fivetoken';
    var type = "pub";
    var silent = true;
    var map = {
      "topic": topic,
      "type": type,
      "payload": payload,
      "silent": silent
    };
    var ps = WCPubSub.fromJson(map);
    expect(ps.topic, topic);
    expect(ps.type, type);
    expect(ps.payload, payload);
    expect(ps.silent, silent);
    expect(ps.toJson(), equals(map));
  });
  group('wc encrypt and decrypt', () {
    var ivHex = 'dbb839e748160e127f0142e637811eff';
    var data = {"fivetoken": "awesome"};
    WCPayload payload;
    var encryptData = {
      "data":
          "d00cff5c6fedc2b01d1ac50a8daeb632754520b4734ad25161369bf36284f6a8",
      "hmac":
          "1658d2f198e2146705755e47ed9d63b1837e05baa7b0b9bf208d8eac520c0908",
      "iv": "dbb839e748160e127f0142e637811eff"
    };
    test("encrypt", () {
      payload = wcEncrypt(jsonEncode(data), keyHex, ivHex);
      expect(payload.toJson(), equals(encryptData));
      expect(1, 1);
    });
    test("decrypt", () {
      var decrypt =
          wcDecrypt(payload.data, keyHex, payload.iv, dataSig: payload.hmac);
      expect(jsonDecode(decrypt), equals(data));
    });
  });
}
