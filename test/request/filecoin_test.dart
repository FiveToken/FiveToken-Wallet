

import 'package:dio/dio.dart';
import 'package:fil/common/shared_preferences.dart';
import 'package:fil/models/token_info.dart';
import 'package:fil/models/transaction_response.dart';
import 'package:fil/repository/http/http.dart';
import 'package:fil/request/filecoin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'filecoin_test.mocks.dart';


@GenerateMocks([
  Filecoin,
  Http,
  PreferencesManagerX
])

void main() {

  final _preferencesManager =  MockPreferencesManagerX();
  PreferencesManagerX().injection(_preferencesManager);
  String to = 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema';
  var _address = 'f1zefmfzccjsqtpnr4ohmlqwrgiywdgbjuy5yc75i';
  var _mockFilecoin = MockFilecoin();
  var _mockHttp = MockHttp();
  var host = 'https://api.fivetoken.io/api/7om8n3ri4v23pjjfs4ozctlb';

  when(
      PreferencesManagerX().getString(any)
  ).thenAnswer(
          (realInvocation) => host
  );

  var _filecoin = new Filecoin('https://api.fivetoken.io');
  test('getBalance', () async {

    when(
        _mockFilecoin.getBalance(_address)
    ).thenAnswer(
            (realInvocation) => Future.value('0')
    );
    final res = await _mockFilecoin.getBalance(_address);
    expect(res, '0');
  });


  test('getBlockByNumber', () async {
    int blockNumber = 13802876;
    final res = await _filecoin.getBlockByNumber(blockNumber);
    expect(res.gasUsed, 0);
  });


  test('getNonce', () async {
    when(
        _mockFilecoin.getNonce(_address)
    ).thenAnswer(
            (realInvocation) => Future.value(1)
    );

    final res = await _filecoin.getNonce(_address);
    expect(res, -1);
  });

  test('getTransactionReceipt', () async {
    String hash = '';
    final res = await _filecoin.getTransactionReceipt(hash);
    expect(res, null);
  });


  test('getBalanceOfToken', () async {
    String mainAddress = '';
    String tokenAddress = '';
    final res = await _filecoin.getBalanceOfToken(mainAddress,tokenAddress);
    expect(res, '0');
  });



  test('fetchPing', () async {
    when(
        PreferencesManagerX().setString(any,any)
    ).thenAnswer(
            (realInvocation) => host
    );

    final res = await fetchPing();
    expect(res.data.substring(0,11), 'https://api');
  });

  test('getBaseFeePerGas', () async {
    final res = await _filecoin.getBaseFeePerGas();
    expect(res, '0');
  });

  test('getBaseFeePerGas', () async {
    final res = await _filecoin.getBaseFeePerGas();
    expect(res, '0');
  });


  test('sendToken', () async {
    final res = await _filecoin.sendToken();
    var result = TransactionResponse(
        cid: '',
        message: ''
    );
    expect(res.cid, '');
  });


  test('getNetworkId', () async {
    final res = await _filecoin.getNetworkId();
    expect(res, '');
  });

  test('getMaxPriorityFeePerGas', () async {
    final res = await _filecoin.getMaxPriorityFeePerGas();
    expect(res, '0');
  });


  test('getTokenInfo', () async {
    var token = TokenInfo(
        symbol: '',
        precision:"0"
    );
    final res = await _filecoin.getTokenInfo('');
    expect(res.precision, token.precision);
  });



}
