import 'package:fil/chain/contract.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/models/gas_response.dart';
import 'package:fil/models/token_info.dart';
import 'package:fil/models/transaction_response.dart';
import 'package:fil/request/provider.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';
import 'package:fil/repository/web3/web3.dart' as web3;
import 'package:fil/models/chain_info.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:fil/repository/web3/json_rpc.dart';

class Ether extends ChainProvider {
  Web3Client client;
  RpcJson rpcJson;
  Ether(String rpc, {Web3Client web3client,RpcJson rpcJson}) {
    this.rpc = rpc;
    final web3Rpc = web3.Web3(rpc);
    client = web3client ?? web3Rpc.client;
    this.rpcJson =  rpcJson ?? web3Rpc.rpcJson;
  }

  /*
  * Returns the message of block number
  * */
  @override
  Future<ChainInfo> getBlockByNumber(int number) async {
    try {
      final res = await rpcJson.call(
          'eth_getBlockByNumber', ['0x${number.toRadixString(16)}', false]);
      var result = res.result;
      if(result['baseFeePerGas'] != null){
        return ChainInfo(
            gasUsed: hexToDartInt(result['gasUsed'] as String),
            gasLimit:hexToDartInt(result['gasLimit'] as String),
            number:hexToDartInt(result['number'] as String),
            timestamp: hexToDartInt(result['timestamp'] as String),
            baseFeePerGas:hexToDartInt(result['baseFeePerGas'] as String)
        );
      }else{
        return ChainInfo(
            gasUsed: hexToDartInt(result['gasUsed'] as String),
            gasLimit:hexToDartInt(result['gasLimit'] as String),
            number:hexToDartInt(result['number'] as String),
            timestamp: hexToDartInt(result['timestamp'] as String)
        );
      }
    } catch (error) {
      return ChainInfo(
        gasUsed: 0,
        gasLimit:0,
        number:0,
        timestamp: 0,
          baseFeePerGas:0
      );
    }
  }

  /*
  * Returns a fee per gas that is an estimate of how much you can pay as a priority fee, or "tip", to get a transaction included in the current block.
  * */
  @override
  Future<String> getMaxPriorityFeePerGas() async{
    try {
      var res = await rpcJson.call('eth_maxPriorityFeePerGas');
      var maxPriority = hexToInt(res.result as String);
      return maxPriority.toString();
    } catch (error) {
      return '0';
    }
  }

  /*
  * get baseFeePerGas
  * */
  @override
  Future<String> getBaseFeePerGas() async{
    try{
      int block = await client.getBlockNumber();
      var blockInfo = await getBlockByNumber(block);
      var baseFee = blockInfo.baseFeePerGas;
      return baseFee.toString();
    }catch(error){
      return '0';
    }
  }

  /*
  * Gets the balance of the account with the specified address.
  * @param {string} address: The address where the balance needs to be obtained
  * */
  @override
  Future<String> getBalance(String address) async {
    String balance = '0';
    try {
      var res = await client.getBalance(EthereumAddress.fromHex(address));
      balance = res.getInWei.toString();
    } catch (e) {
      return '0';
    }
    return balance;
  }

  /*
  * Gets the balance of token
  * @param {string} mainAddress:main token address
  * @param {string} tokenAddress:contract address
  * */
  @override
  Future<String> getBalanceOfToken(String mainAddress,String tokenAddress) async{
    var abi = ContractAbi.fromJson(Contract.abi, 'bnb');
    var con = DeployedContract(abi, EthereumAddress.fromHex(tokenAddress));
    String balance = '0';
    try {
      var list = await client.call(
          contract: con,
          function: con.function('balanceOf'),
          params: [EthereumAddress.fromHex(mainAddress)]);
      if (list.isNotEmpty) {
        var numStr = list[0];
        if (numStr is BigInt) {
          balance = numStr.toString();
        }
      }
      return balance;
    } catch (e) {
      return balance;
    }
  }

  /*
  * Get fee
  * @param {string} from: sending transaction from address
  * @param {string} to:  sending transaction to address
  * @param {bool} isToken: is it a token
  * @param {Token} token: Token Information
  * */
  @override
  Future<GasResponse> getGas({String from, String to, bool isToken = false, Token token }) async {
    var empty = GasResponse();
    var fromAddress = EthereumAddress.fromHex(from);
    var toAddr = EthereumAddress.fromHex(to);
    try {
      List<dynamic> res = [];
      if (token != null) {
        var abi = ContractAbi.fromJson(Contract.abi, '');
        var con = DeployedContract(abi, EthereumAddress.fromHex(token.address));
        var data = con
            .function('transfer')
            .encodeCall([EthereumAddress.fromHex(to), BigInt.from(1)]);
        res = await Future.wait([
          client.getGasPrice(),
          client.estimateGas(
              to: EthereumAddress.fromHex(token.address),
              sender: fromAddress,
              data: data,
              value: EtherAmount.fromUnitAndValue(EtherUnit.wei, 0))
        ]);
      } else {
        res = await Future.wait([
          client.getGasPrice(),
          client.estimateGas(
              to: toAddr,
              value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0))
        ]);
      }
      if (res.length == 2) {
        EtherAmount gasPrice = res[0] as EtherAmount;
        BigInt gasLimit = res[1] as BigInt;
        int realLimit = gasLimit.toInt();
        if (isToken) {
          realLimit = (gasLimit.toInt() * 2).truncate();
        }
        return GasResponse(
          gasState: "success",
          gasLimit: realLimit,
          gasPrice: (gasPrice.getInWei).toString()
        );
      } else {
        return GasResponse(
            gasState: "error",
            gasLimit: 0,
            gasPrice: ''
        );
      }
    } catch (error) {
      if(error.message.isNotEmpty as bool){
        return GasResponse(
            gasState: "error",
            message: error.message as String
        );
      }else{
        return GasResponse(
            gasState: "error",
            message: ''
        );
      }
    }
  }

  /*
  * Get address nonce by the specified address
  * @param {string} address: the specified address
  * */
  @override
  Future<int> getNonce(String address) async {
    try {
      return await client.getTransactionCount(
          EthereumAddress.fromHex(address));
    } catch (e) {
      return -1;
    }
  }

  /*
  * Returns a hash of the transaction which, after the transaction has been included in a mined block,
  * can be used to obtain detailed information about the transaction.
  * @param {string} from: sending transaction from address
  * @param {string} to:  sending transaction to address
  * @param {String} amount：Amount sent
  * @param {String} private：private of sending transactions
  * @param {int} nonce：nonce of sending transactions
  * */
  @override
  Future<TransactionResponse> sendTransaction(
      String from,
      String to,
      String amount,
      String private,
      ChainGas gas,
      int nonce
  ) async {
    try {
      var credentials = await client.credentialsFromPrivateKey(private);
      Transaction _transaction;
      if(gas.rpcType == RpcType.ethereumMain){
        _transaction = Transaction(
          from:EthereumAddress.fromHex(from),
          to: EthereumAddress.fromHex(to),
          maxFeePerGas: EtherAmount.inWei(BigInt.parse(gas.maxFeePerGas)),
          maxPriorityFeePerGas: EtherAmount.inWei(BigInt.parse(gas.maxPriorityFee)),
          maxGas: gas.gasLimit,
          nonce: nonce,
          value: EtherAmount.inWei(BigInt.parse(amount)),
        );
      }else{
        _transaction = Transaction(
          from:EthereumAddress.fromHex(from),
          to: EthereumAddress.fromHex(to),
          gasPrice: EtherAmount.inWei(BigInt.parse(gas.gasPrice)),
          maxGas: gas.gasLimit,
          nonce: nonce,
          value: EtherAmount.inWei(BigInt.parse(amount)),
        );
      }
      var res = await client.sendTransaction(
          credentials,
          _transaction,
          chainId: int.tryParse($store.net.chainId) ?? 1);
      return TransactionResponse(
        cid: res,
        message: ''
      );
    } catch (e) {
      String msg = e.message as String ?? '';
      return TransactionResponse(
          cid: '',
          message:  msg ?? ''
      );
    }
  }

  /*
  * send token and Returns a hash
  * @param {string} to:  sending transaction to address
  * @param {String} amount：Amount sent
  * @param {String} private：private of sending transactions
  * @param {ChainGas} gas:transactions gas
  * @param {string} addr:contract address
  * @param {int} nonce：nonce of sending transactions
  * */
  @override
  Future<TransactionResponse> sendToken(
      {String to,
        String amount,
        String private,
        ChainGas gas,
        String addr,
        int nonce}
    ) async {
    try {
      var credentials = await client.credentialsFromPrivateKey(private);
      var abi = ContractAbi.fromJson(Contract.abi, '');
      var con = DeployedContract(abi, EthereumAddress.fromHex(addr));
      var transaction = Transaction.callContract(
          contract: con,
          function: con.function('transfer'),
          parameters: [EthereumAddress.fromHex(to), BigInt.parse(amount)],
          maxGas: gas.gasLimit,
          nonce: nonce,
          gasPrice: EtherAmount.inWei(BigInt.parse(gas.gasPrice)));
      var res = await client.sendTransaction(credentials, transaction,
          chainId: int.tryParse($store.net.chainId) ?? 1);
      return TransactionResponse(
        cid: res, message: ''
      );
    } catch (e) {
      return TransactionResponse(
        cid: '', message:e.message as String
      );
    }
  }

  /*
  * get Token Information
  * @param { string } Token contract address
  * */
  @override
  Future<TokenInfo> getTokenInfo(String address) async{
    var empty = TokenInfo(
        symbol: '',
        precision:"0"
    );
    try{
      var abi = ContractAbi.fromJson(Contract.abi, 'bnb');
      var con = DeployedContract(abi, EthereumAddress.fromHex(address));

      var lists = await Future.wait([
        client.call(contract: con, function: con.function('symbol'), params: []),
        client.call(contract: con, function: con.function('decimals'), params: [])
      ]);
      if (lists.isNotEmpty) {
        var symbol = lists[0];
        var decimals = lists[1];
        if (symbol.isNotEmpty && decimals.isNotEmpty) {
          return TokenInfo(
              symbol: symbol[0].toString(),
              precision: decimals[0].toString()
          );
        } else {
          return empty;
        }
      }
    }catch(error){
      return empty;
    }
  }

  /*
  * Returns the id of the network the client is currently connected to.
  * */
  @override
  Future<String> getNetworkId() async{
    try{
      var id = await client.getNetworkId();
      return id.toString();
    }catch(error){
      return '';
    }
  }

  /*
  * Returns an receipt of a transaction based on its hash.
  * @param {string} hash: transaction hash
  * */
  @override
  Future getTransactionReceipt(String hash) async{
    var res = await client.getTransactionReceipt(hash);
    return res;
  }

  /*
  * address check
  * @param {string} address:address to check
  * */
  // @override
  // Future<bool> addressCheck(String address) async{
  //   return false;
  // }

  /*
  * get fileCoin messages list
  * @param {string} actor:address to query
  * @param {string} direction : up or down, indicating the operation action of the client, up means swiping up, pulling from the latest news to historical news; down means pulling down to refresh, pulling the latest news
  * @param {string} mid : The message MID of the pagination reference, obtained from the first or last entry in the query list, is a numeric string, not a CID
  * @param {int} limit: Number of bars
  * */
  @override
  Future<List> getFileCoinMessageList({String actor ,String direction, String mid,int limit}) async{
    return [];
  }

  /*
  * Query pending messages information
  *  @param {List} param:[{
  * from:Transaction sending address,
  * nonce: Transaction nonce
  * }]
  * */
  @override
  Future<List> getMessagePendingState(List param) async{
    return [];
  }

  @override
  void dispose() {
    client.dispose();
  }
}
