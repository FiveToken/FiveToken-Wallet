import 'package:fil/chain/token.dart';
import 'package:fil/models-new/chain_gas.dart';
import 'package:fil/models-new/chain_info.dart';

abstract class ChainProvider {
  String rpc;

  Future<String> getBalance(String address);

  Future<String> sendTransaction({
    String to,
    String amount,
    String private,
    ChainGas gas,
    int nonce,
  });

  Future<ChainGas> getGas({String to, bool isToken = false, Token token});

  Future<int> getNonce();

  ChainGas replaceGas(ChainGas gas, {String chainPremium});

  Future<ChainInfo> getBlockByNumber(int number);

  Future getTransactionReceipt(String hash);

  Future<List> getFileCoinMessageList({String actor ,String direction, String mid,int limit});

  Future<List> getMessagePendingState(List params);

  Future<String> getBalanceOfToken(String mainAddress,String tokenAddress);

  Future<String> getMaxPriorityFeePerGas();

  Future<String> getMaxFeePerGas();

  void dispose();
}
