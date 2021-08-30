import 'package:fil/index.dart';
import 'package:hive/hive.dart';
part 'cacheMessage.g.dart';

class MessageDetail {
  String to,
      from,
      value,
      gasPrice,
      params,
      gasFeeCap,
      gasPremium,
      minerTip,
      baseFeeBurn,
      blockCid,
      signedCid,
      methodName,
      allGasFee,
      overEstimationBurn;
  num version, nonce, gasLimit, method, blockTime, exitCode, pending, height;
  dynamic args;
  MessageDetail(
      {this.to = '',
      this.from = '',
      this.value = '0',
      this.gasFeeCap = '0',
      this.gasPremium = '0',
      this.gasLimit = 0,
      this.minerTip = '0',
      this.baseFeeBurn = '0',
      this.overEstimationBurn = '0',
      this.allGasFee = '0',
      this.version,
      this.nonce,
      this.method,
      this.height,
      this.blockCid = '',
      this.args,
      this.methodName = '',
      this.signedCid = ''});
  MessageDetail.fromJson(Map<String, dynamic> json)
      : this.version = json['version'],
        this.to = json['to'],
        this.from = json['from'],
        this.value = json['value'],
        this.gasPrice = json['gas_price'],
        this.gasLimit = json['gas_limit'],
        this.params = json['params'],
        this.nonce = json['nonce'],
        this.method = json['method'],
        this.methodName = json['method_name'],
        this.gasFeeCap = json['gas_fee_cap'],
        this.gasPremium = json['gas_premium'],
        this.minerTip = json['miner_tip'],
        this.baseFeeBurn = json['base_fee_burn'],
        this.overEstimationBurn = json['over_estimation_burn'],
        this.blockTime = json['block_time'],
        this.height = json['height'],
        this.signedCid = json['signed_cid'],
        this.exitCode = json['exit_code'],
        this.allGasFee = json['all_gas_fee'],
        this.args = json['args'];
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "to": this.to,
      "from": this.from,
      "value": this.value,
      "nonce": this.nonce,
    };
  }
}

@HiveType(typeId: 4)
class StoreMessage {
  @HiveField(0)
  String from;
  @HiveField(1)
  String to;
  @HiveField(2)
  String owner;
  @HiveField(3)
  String signedCid;
  @HiveField(4)
  String value;
  @HiveField(5)
  num blockTime;
  @HiveField(6)
  num exitCode;
  @HiveField(7)
  num pending;
  @HiveField(8)
  String args;
  @HiveField(9)
  num nonce;
  StoreMessage(
      {this.from,
      this.to,
      this.signedCid,
      this.value,
      this.blockTime = 0,
      this.owner,
      this.pending,
      this.args,
      this.nonce = 0,
      this.exitCode});
  StoreMessage.fromJson(Map<dynamic, dynamic> json)
      : this.signedCid = json['signed_cid'],
        this.to = json['to'],
        this.from = json['from'] ?? 0,
        this.value = json['value'],
        this.blockTime = json['block_time'],
        this.exitCode = json['exit_code'],
        this.owner = json['owner'],
        this.args = jsonEncode(json['args']),
        this.pending = json['pending'],
        this.nonce = json['nonce'];
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'signed_cid': this.signedCid,
      'to': this.to,
      'from': this.from,
      'value': this.value,
      'block_time': this.blockTime,
      'exit_code': this.exitCode,
      'pending': this.pending,
      'owner': this.owner,
      'args': this.args,
      'nonce': this.nonce
    };
  }
}

@HiveType(typeId: 11)
class CacheMessage {
  @HiveField(0)
  String from;
  @HiveField(1)
  String to;
  @HiveField(2)
  String owner;
  @HiveField(3)
  String hash;
  @HiveField(4)
  String value;
  @HiveField(5)
  num blockTime;
  @HiveField(6)
  num exitCode;
  @HiveField(7)
  num pending;
  @HiveField(8)
  num nonce;
  @HiveField(9)
  String rpc;
  @HiveField(10)
  ChainGas gas;
  @HiveField(11)
  Token token;
  @HiveField(12)
  String fee;
  @HiveField(13)
  int height;
  @HiveField(14)
  String mid; //only for filecoin
  CacheMessage(
      {this.from = '',
      this.to = '',
      this.hash = '',
      this.value = '0',
      this.blockTime = 0,
      this.owner = '',
      this.pending = 1,
      this.nonce = 0,
      this.rpc = '',
      this.gas,
      this.token,
      this.fee = '',
      this.height = 0,
      this.mid='',
      this.exitCode});
  String get formatValue {
    if (token != null) {
      return token.getFormatBalance(value);
    } else {
      return formatCoin(value);
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'signed_cid': hash,
      'to': to,
      'from': from,
      'value': value,
      'block_time': blockTime,
      'exit_code': exitCode,
      'pending': pending,
      'owner': owner,
      'nonce': nonce,
      'gas': gas,
      'token': token,
      'fee': fee,
      'height': height
    };
  }
}
