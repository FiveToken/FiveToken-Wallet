import 'package:fil/chain/gas.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/models/chain_info.dart';

abstract class ChainProvider {
  String rpc;

  Future<String> getBalance(String address);

  Future<String> sendTransaction(
      String from,
      String to,
      String amount,
      String private,
      ChainGas gas,
      int nonce,
  );

  Future<String> sendToken(
      String from,
      String to,
      String amount,
      String private,
      ChainGas gas,
      int nonce
  );

  Future<ChainGas> getGas({String to, bool isToken = false, Token token});

  Future<int> getNonce(String address);

  Future<ChainInfo> getBlockByNumber(int number);

  Future getTransactionReceipt(String hash);

  Future<List> getFileCoinMessageList({String actor ,String direction, String mid,int limit});

  Future<List> getMessagePendingState(List params);

  Future<String> getBalanceOfToken(String mainAddress,String tokenAddress);

  Future<String> getMaxPriorityFeePerGas();

  Future<String> getMaxFeePerGas();

  Future<List> getTokenPrice(List param);

  Future<bool> addressCheck(String address);

  Future<String> getNetworkId();

  void dispose();
}