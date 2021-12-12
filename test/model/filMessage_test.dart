import 'package:flutter_test/flutter_test.dart';
import 'package:fil/models/filMessage.dart';
void main() {
  TMessage tm = TMessage(
      version: 0,
      method: 0,
      nonce: 553,
      from: 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
      to: 'f13kyxxxaarg2ndzju5fzzcr366tuwhhat7whspzi',
      params: "",
      value: '20000000000000',
      gasFeeCap: '121542',
      gasLimit: 2200000,
      gasPremium: '121083'
  );
  Signature sign = Signature.fromJson({
    'type':1,
    'data': 'kLnAEYmM756FkfxyZaIvZmYMjV6M0DOMqL7tQ8SMVZdsL68e1slQa1gPFUruZhAdlzBXSIqe7PKaNcSIbN6zsQA='
  });
  test("generate model filMessage", () async {
    tm.toJson();
    tm.toLotusMessage();
    tm.valid;
    expect(tm.valid, true);
  });

  test("generate model Signature", () async {
    Signature sign1 = Signature(2,'kLnAEYmM756FkfxyZaIvZmYMjV6M0DOMqL7tQ8SMVZdsL68e1slQa1gPFUruZhAdlzBXSIqe7PKaNcSIbN6zsQA=');
    sign1.toJson();
    var res = 'kLnAEYmM756FkfxyZaIvZmYMjV6M0DOMqL7tQ8SMVZdsL68e1slQa1gPFUruZhAdlzBXSIqe7PKaNcSIbN6zsQA=';
    expect(sign1.data, res);

  });

  test("generate model SignedMessage", () async {
    SignedMessage signMsg = SignedMessage(tm, sign);
    Map<String, dynamic> json = signMsg.toJson();
    signMsg.toLotusSignedMessage();
    expect(json['Message'].nonce, 553);
  });

}