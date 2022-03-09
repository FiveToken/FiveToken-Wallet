import 'package:fil/repository/web3/rpc_interceptors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test web3 rpc ', (tester) async {
    var json = {
      'code': 200,
      'msg': 'secuess',
      'data': {
        'address': '0x3fb4f280cf531ba7d88fe4d0748a451e4d4276ad',
        'rpc': 'https://mainnet.infura.io/v3/'
      }
    };
    RpcResponseData interceptors = RpcResponseData.formJson(json);
    interceptors.toString();
    var json2 = interceptors.toJson();
    expect(json2['msg'], json['msg']);
    expect(interceptors.success, true);
  });
}