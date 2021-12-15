import 'package:fil/actions/event.dart';
import 'package:fil/chain/token.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  test("generate actions event ", () async {
    Token token  = Token.fromJson({
      'symbol': 'FIL',
      'precision': 0,
      'address': 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
      'chain': 'eth',
      'rpc': 'https://api.fivetoken.io',
      'balance':'100000000000000'
    });
    RefreshEvent(token: token);
  });
}