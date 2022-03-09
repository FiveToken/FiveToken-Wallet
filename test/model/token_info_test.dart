import 'package:fil/models/token_info.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  test("generate model token_info", () async {
     TokenInfo tokenInfo = TokenInfo(
       symbol: 'five',
       precision: 'token'
     );
     var json = tokenInfo.toJson();
     TokenInfo tokenInfo2 = TokenInfo.fromJson(json);
     expect(tokenInfo2.symbol, 'five');
  });
}