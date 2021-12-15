import 'package:fil/models/chain_info.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  test("generate model address", () async {
    var json = {
      'gasUsed': '0',
      'gasLimit':'0',
      'number':'0',
      'timestamp': '0',
      'baseFeePerGas': '0'
    };
    ChainInfo chainInfo = ChainInfo.fromJson(json);
    var resJson = chainInfo.toJson();
    expect(resJson, json);
  });
}