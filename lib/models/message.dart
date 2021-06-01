import 'package:fil/index.dart';
import 'package:hive/hive.dart';
part 'message.g.dart';

class Receipt {
  String ret;
  num exitCode, gasUsed;

  Receipt(this.exitCode, this.gasUsed, this.ret);

  Receipt.fromJson(Map<String, dynamic> json)
      : this.ret = json['return'],
        this.exitCode = json['exit_code'],
        this.gasUsed = json['gas_used'];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "return": this.ret,
      "gas_used": this.gasUsed,
      "exit_code": this.exitCode,
    };
  }
}

class Message {
  String to, from, value, gasPrice, params, gasFeeCap, gasPremium;
  num version, nonce, gasLimit, method;

  Message(
      {this.version,
      this.to,
      this.from,
      this.value,
      this.gasPrice,
      this.gasLimit,
      this.params,
      this.nonce,
      this.method,
      this.gasFeeCap,
      this.gasPremium});

  Message.fromJson(Map<String, dynamic> json)
      : this.version = json['version'],
        this.to = json['to'],
        this.from = json['from'],
        this.value = json['value'],
        this.gasPrice = json['gas_price'],
        this.gasLimit = json['gas_limit'],
        this.params = json['params'],
        this.nonce = json['nonce'],
        this.method = json['method'],
        this.gasFeeCap = json['gas_fee_cap'],
        this.gasPremium = json['gas_premium'];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "version": this.version,
      "to": this.to,
      "from": this.from,
      "value": this.value,
      "gas_price": this.gasPrice,
      "gas_limit": this.gasLimit,
      "gas_premium": this.gasPremium,
      "gas_fee_cap": this.gasFeeCap,
      "params": this.params,
      "nonce": this.nonce,
      "method": this.method,
    };
  }
}

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

class WrappedMessage {
  dynamic message, receipt, signature;
  String cid, blockCid, requiredFunds;
  num blockHeight, size, timestamp, pushTime, status;

  WrappedMessage(this.message, this.cid, this.blockCid, this.requiredFunds,
      this.blockHeight, this.size, this.timestamp, this.pushTime, this.status);

  WrappedMessage.fromJson(Map<String, dynamic> json)
      : this.message = json['message'],
        this.cid = json['cid'],
        this.blockCid = json['block_cid'],
        this.requiredFunds = json['required_funds'],
        this.blockHeight = json['block_height'],
        this.size = json['size'],
        this.timestamp = json['timestamp'],
        this.pushTime = json['push_time'],
        this.status = json['status'],
        this.receipt = json['receipt'],
        this.signature = json['signature'];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "message": this.message,
      "cid": this.cid,
      "block_cid": this.blockCid,
      "required_funds": this.requiredFunds,
      "block_height": this.blockHeight,
      "size": this.size,
      "timestamp": this.timestamp,
      "push_time": this.pushTime,
      "status": this.status,
      "receipt": this.receipt,
      "signature": this.signature,
    };
  }
}
