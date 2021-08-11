import 'package:fil/index.dart';
import './fetch.dart';
var messageApi = 'https://api.filwallet.ai:5679/rpc/v0';

/// push signed message to lotus 
Future<String> pushSignedMsg(Map<String, dynamic> msg) async {
  if (!Global.online) {
    showCustomError('errorNet'.tr);
  }
  var data = JsonRPCRequest(1, "Filecoin.MessagePush", [msg]);
  try {
    var rs = await Dio().post(
      messageApi,
      data: data,
    );
    print(jsonEncode(data));
    print(rs);
    var res = JsonRPCResponse.fromJson(rs.data);
    if (res.error != null) {
      showCustomError(res.error['message']);
      Map<String, dynamic> params = {};
      var m = msg['Message'];
      params['from'] = m['From'];
      params['to'] = m['To'];
      params['value'] = m['Value'];
      params['method'] = m['Method'];
      params['err_msg'] = res.error['message'];
      return '';
    } else if (res.result != null && res.result['/'] != null) {
      return res.result['/'];
    } else {
      return '';
    }
  } catch (e) {
    print(e);
    return '';
  }
}

/// get messages related to the specified address
///  [address]  address use to search
///  [timePoint]  tipset timestamp
///  [direction]  'up': find messages before [timePoint] 'down': find messages after [timePoint]
///  [count] num of the messages 
///  [method] message's method
Future<List> getMessageList(
    {String address = '',
    num time,
    String direction = 'up',
    num count = 80}) async {
  time ??= (DateTime.now().millisecondsSinceEpoch / 1000).truncate() - 3600;
  var data = JsonRPCRequest(1, "filscan.MessageByAddressDirection", [
    {
      "address": address,
      "timePoint": time,
      "direction": direction,
      "count": count,
      "method": ""
    }
  ]);
  print(jsonEncode(data));
  var result =
      await baseRequest.post('/rpc/v1', data: data).catchError((value) {
    print(value);
  });

  var response = JsonRPCResponse.fromJson(result.data);
  if (response.error != null) {
    return [];
  }
  var res = response.result;
  if (res != null) {
    if (res["data"] != null && res['data'] is List) {
      return res['data'];
    } else {
      return [];
    }
  } else {
    return [];
  }
}

/// get the message detail infomation by signed cid
Future<MessageDetail> getMessageDetail(StoreMessage mes) async {
  if (!Global.online) {
    showCustomError('errorNet'.tr);
  }
  var data = JsonRPCRequest(1, "filscan.MessageDetails", [mes.signedCid]);
  var result = await baseRequest
      .post(
    "/rpc/v1",
    data: data,
  )
      .catchError((e) {
    print(e);
  });
  var response = JsonRPCResponse.fromJson(result.data);
  if (response.error != null) {
    return MessageDetail.fromJson(mes.toJson());
  }
  var res = response.result;
  if (res != null) {
    var message = MessageDetail.fromJson(res);
    message.blockCid = res['blk_cids'] != null ? res['blk_cids'][0] : '';
    return message;
  } else {
    return MessageDetail.fromJson(mes.toJson());
  }
}

/// get gas_limit,gas_premium and base_fee to predict gas 
///  [method]  'method' filed in message
///  [to] 'to' field in message
Future<Gas> getGasDetail({num method = 0, String to}) async {
  if (!Global.online) {
    showCustomError('errorNet'.tr);
  }
  if (to == null) {
    to = Global.netPrefix + '099';
  }
  var data = JsonRPCRequest(1, "filscan.BaseFeeAndGas", [to, method]);
  var empty = Gas();
  var result = await baseRequest
      .post(
    "/rpc/v1",
    data: data,
  )
      .catchError((e) {
    print(e);
  });
  print(result);
  var response = JsonRPCResponse.fromJson(result.data);

  if (response.error != null) {
    return empty;
  }
  var res = response.result;
  if (res != null) {
    var baseFee = res['base_fee'] ?? '0';
    var gasUsed = res['gas_used'] ?? '0';
    var exist = res['actor_exist'] ?? true;
    try {
      var baseFeeNum = int.parse(baseFee);
      var gasUsedNum = int.parse(gasUsed);
      var feeCap = max(3 * baseFeeNum, 5 * pow(10, 9));
      var premium = pow(10, 6);
      var gasLimit = exist ? (gasUsedNum * 1.25).truncate() : 2200000;
      return Gas(
          gasUsed: gasUsedNum,
          baseFee: baseFeeNum.toString(),
          feeCap: feeCap.toString(),
          premium: premium.toString(),
          gasLimit: gasLimit);
    } catch (e) {
      return empty;
    }
  } else {
    return empty;
  }
}
