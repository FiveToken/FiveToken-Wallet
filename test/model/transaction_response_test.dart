import 'package:fil/models/transaction_response.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  test("generate model transcation_response", () async {
    var transaction_json = {
      'cid': '0xa45bc341e17e7bb8c3183644f6293e0a6d16071e',
      'message': 'f13kyxxxaarg2ndzju5fzzcr366tuwhhat7whspzi'
    };
    TransactionResponse transactionResponse = TransactionResponse.fromJson(transaction_json);
    var json = transactionResponse.toJson();
    expect(json, transaction_json);
  });
}