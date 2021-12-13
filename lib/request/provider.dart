import 'package:fil/chain/gas.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/models/chain_info.dart';
import 'package:fil/models/gas_response.dart';
import 'package:fil/models/token_info.dart';
import 'package:fil/models/transaction_response.dart';

abstract class ChainProvider {
  String rpc;

  Future<String> getBalance(String address);

  Future<TransactionResponse> sendTransaction(
      String from,
      String to,
      String amount,
      String private,
      ChainGas gas,
      int nonce,
  );

  Future<TransactionResponse> sendToken(
      {String to,
        String amount,
        String private,
        ChainGas gas,
        String addr,
        int nonce}
  );

  Future<GasResponse> getGas({String to, bool isToken = false, Token token});

  Future<int> getNonce(String address);

  Future<ChainInfo> getBlockByNumber(int number);

  Future getTransactionReceipt(String hash);

  Future<List> getFileCoinMessageList({String actor ,String direction, String mid,int limit});

  Future<List> getMessagePendingState(List params);

  Future<String> getBalanceOfToken(String mainAddress,String tokenAddress);

  Future<String> getMaxPriorityFeePerGas();

  Future<String> getMaxFeePerGas();

  Future<bool> addressCheck(String address);

  Future<String> getNetworkId();

  Future<TokenInfo> getTokenInfo(String address);

  void dispose();
}
