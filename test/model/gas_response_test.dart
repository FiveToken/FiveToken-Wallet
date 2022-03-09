import 'package:fil/models/gas_response.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  test("generate model gas response", () async {
    GasResponse gas = GasResponse(
      gasLimit: 12,
      gasPrice: '0xa45bc341e17e7bb8c3183644f6293e0a6d16071e',
      gasState: 'https://api.calibration.fivetoken.io',
      message: '',
      gasFeeCap: '',
      gasPremium: ''
    );
    Map<String, dynamic> gasJson = gas.toJson();
    GasResponse gasRes = GasResponse.fromJson(gasJson);
    expect(gasJson['gasLimit'], 12);
    expect(gasRes.gasLimit, 12);
  });
}