import 'package:fil/index.dart';


/// get nonce of an address
Future<int> getNonce(Wallet w) async {
  var data = JsonRPCRequest(1, "filscan.BalanceNonceByAddress", [
    {"address": w.address},
  ]);
  var rs = await baseRequest
      .post(
    "/rpc/v1",
    data: data,
  )
      .catchError((e) {
    print(e);
  });
  if (rs == null) {
    return -1;
  }
  var res = JsonRPCResponse.fromJson(rs.data);
  if (res.error != null) {
    var error = JsonRPCError.fromJson(res.error);
    print(error.message);
    return -1;
  }
  var r = -1;
  if (res.result != null) {
    var result = res.result as Map<String, dynamic>;
    r = result["nonce"];
  }
  return r == null ? -1 : r;
}

Future<BalanceNonce> getBalance(Wallet w) async {
  var rs = await fetch("filscan.BalanceNonceByAddress", [
    {"address": w.address},
  ]);
  print(rs);
  var balanceNonce = BalanceNonce();
  if (rs == null) {
    return balanceNonce;
  }
  var res = JsonRPCResponse.fromJson(rs.data);
  if (res.error != null) {
    var error = JsonRPCError.fromJson(res.error);
    print(error.message);
    return balanceNonce;
  }

  if (res.result != null) {
    var result = res.result as Map<String, dynamic>;
    balanceNonce.balance = Fil(attofil: result["balance"] as String).toString();
    balanceNonce.nonce = result["nonce"] as num;
  }
  return balanceNonce;
}

/// get balance and nonce of an address
Future<WalletMeta> getWalletMeta(String address) async {
  var rs = await fetch("filscan.BalanceNonceByAddress", [
    {"address": address},
  ]);
  var defaultInfo = WalletMeta(balance: '0', nonce: -1);
  if (rs == null) {
    return defaultInfo;
  }
  var res = JsonRPCResponse.fromJson(rs.data);
  if (res.error != null) {
    var error = JsonRPCError.fromJson(res.error);
    print(error.message);
    return defaultInfo;
  }
  if (res.result != null) {
    var result = res.result as Map<String, dynamic>;
    var balance = Fil(attofil: result["balance"] as String).toString();
    var nonce = result["nonce"] as int;
    return WalletMeta(balance: balance, nonce: nonce);
  }
  return defaultInfo;
}
