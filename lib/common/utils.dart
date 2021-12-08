import 'package:decimal/decimal.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:fil/request/global.dart';
import 'package:fil/utils/decimal_extension.dart';
import 'package:fil/utils/string_extension.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:fil/utils/num_extension.dart';

const psalt = "vFIzIawYOU";

String aesDecrypt(String raw, String mix) {
  if (raw == '') {
    return '';
  }
  var m = sha256.convert(base64.decode(mix));
  var key = encrypt.Key.fromBase64(base64.encode(m.bytes));
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cfb64));
  final encrypted = encrypt.Encrypted(base64.decode(raw));
  var decoded = encrypter.decrypt(encrypted, iv: encrypt.IV.fromLength(16));
  return decoded;
}

String aesEncrypt(String raw, String mix) {
  if (raw == '') {
    return '';
  }
  var m = sha256.convert(base64.decode(mix));
  var key = encrypt.Key.fromBase64(base64.encode(m.bytes));
  final encrypter =
      encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cfb64));
  var encoded = encrypter.encrypt(raw, iv: encrypt.IV.fromLength(16));
  return encoded.base64;
}

String tokenify(String str, {String salt = psalt}) {
  var key = utf8.encode(salt);
  var bytes = utf8.encode(str.trim());

  var hmacSha = new Hmac(sha1, key); // HMAC-SHA1
  var digest = hmacSha.convert(bytes);
  return digest.toString();
}

void unFocusOf(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

void copyText(String text, {Function callback}) {
  var data = ClipboardData(text: text);
  Clipboard.setData(data).then((_) {
    if (callback != null) {
      callback();
    }
  });
}

String dotString({String str = '', int headLen = 6, int tailLen = 6}) {
  int strLen = str.length;
  if (strLen < headLen + tailLen) {
    return str;
  }
  String headStr = str.substring(0, headLen);
  int tailStart = strLen - tailLen;
  String tailStr = "";
  if (tailStart > 0) {
    tailStr = str.substring(tailStart, strLen);
  }

  return "$headStr...$tailStr";
}

bool isDecimal(String input) {
  var r = RegExp(r"(^\d+(?:\.\d+)?([eE]-?\d+)?$|^\.\d+([eE]-?\d+)?$)");
  if (r.hasMatch(input.trim())) {
    return true;
  }
  return false;
}

bool isValidContractAddress(address){
  var start = address.startsWith('0x');
  var reg = RegExp(r"([A-Fa-f0-9]$)");
  var valid = reg.hasMatch(address);
  return start && valid;
}

Future<bool> isValidChainAddress(String address, Network network) async {
  bool res = false;
  try{
    if(network.addressType == 'filecoin'){
      Chain.setRpcNetwork(network.rpc, network.chain);
      res = await Chain.chainProvider.addressCheck(address);
      print('res');
    }else{
      var start = address.startsWith('0x');
      var reg = RegExp(r"([A-Fa-f0-9]{40}$)");
      var valid = reg.hasMatch(address);
      res = start && valid;
    }
    return res;
  }catch(error){
    print('error');
    return false;
  }
}

String genCKBase64(String mne, {String path}) {
  var seed = bip39.mnemonicToSeed(mne);
  bip32.BIP32 nodeFromSeed = bip32.BIP32.fromSeed(seed);
  var rs = nodeFromSeed.derivePath(path??"m/44'/461'/0'/0");
  var rs0 = rs.derive(0);
  var ck = path!="m/44'/60'/0'/0" ? base64Encode(rs0.privateKey):hex.encode(rs0.privateKey);
  return ck;
}

String hex2str(String hexString) {
  hexString = hexString.trim();
  List<String> split = [];
  for (int i = 0; i < hexString.length; i = i + 2) {
    split.add(hexString.substring(i, i + 2));
  }
  String ascii = List.generate(split.length,
      (i) => String.fromCharCode(int.parse(split[i], radix: 16))).join();
  return ascii;
}

String truncate(double value, {int size = 4}) {
  return ((value * pow(10, size)).floor() / pow(10, size)).toString();
}

String formatCoin(String amount, { num size = 4, double min, int precision = 18 }) {
  if (amount == '0') {
    return '0';
  }
  try {
    var _amount = double.parse(amount)/pow(10, precision);
    var _decimal = _amount.toDecimal;
    var res = _decimal.fmtDown(size);
    String esc = '';
    if((min.runtimeType.toString() == 'double' || min.runtimeType.toString() == 'int' ) && (_amount < min)){
      return  min.toStringAsFixed(7) + '0...';
    }else{
      return  res ;
    }

  } catch (e) {
    return amount;
  }
}

String getChainValue(String fil, {int precision = 18}) {
  try{
    var _value = Decimal.parse(fil) * Decimal.fromInt(pow(10, 18));
    var _amount = Decimal.parse(_value.toString()) * Decimal.fromInt(pow(10, precision))/Decimal.fromInt(pow(10,18));
    var _decimal = _amount.toString().toDecimal;
    var res = _decimal.fmtDown(0);
    return res;
  }catch(error){
    print('error');
  }
}

bool ethPrivate(str){
  RegExp eth = RegExp(r'^(0x)?[0-9A-Za-f]{64}');
  return eth.hasMatch(str)&&str.length==64;
}

int getSecondSinceEpoch() {
  return (DateTime.now().millisecondsSinceEpoch / 1000).truncate();
}

String formatDouble(String str, {bool truncate = false, int size = 4}) {
  try {
    var v = double.parse(str);
    if (v == 0.0) {
      return '0';
    } else {
      if (truncate) {
        return ((v * pow(10, size)).floor() / pow(10, size)).toString();
      } else {
        return str;
      }
    }
  } catch (e) {
    return '0';
  }
}

String base64ToHex(String pk, String type) {
  String t = type == '1' ? 'secp256k1' : 'bls';
  PrivateKey privateKey = PrivateKey(t, pk);
  String result = '';
  var list = BinaryWriter.utf8Encoder.convert(jsonEncode(privateKey.toJson()));
  for (var i = 0; i < list.length; i++) {
    result += list[i].toRadixString(16);
  }
  return result;
}

Future openInBrowser(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: false,
      forceWebView: false,
    );
  } else {
    throw 'Could not launch $url';
  }
}

bool isValidPassword(String pass) {
  pass = pass.trim();
  var reg = RegExp(r'^(?=.*[0-9].*)(?=.*[A-Z].*)(?=.*[a-z].*).{8,20}$');
  return reg.hasMatch(pass);
}

bool isValidPass(String pass){
  pass = pass.trim();
  return pass.length > 11;
}

bool isValidUrl(String url) {
  final urlRegExp = new RegExp(
      r"^(https?:\/\/(([a-zA-Z0-9]+-?)+[a-zA-Z0-9]+\.)+[a-zA-Z]+)(:\d+)?(\/.*)?(\?.*)?(#.*)?$");
  return urlRegExp.hasMatch(url);
}

void nextTick(Noop callback) {
  Future.delayed(Duration.zero).then((value) {
    callback();
  });
}

String getValidWCLink(String link) {
  bool Function(String) fullLink =
      (String url) => url.contains('bridge') && url.contains('key');
  if (!fullLink(link)) {
    return '';
  } else {
    if (link.startsWith('wc:')) {
      return link;
    } else if (link.startsWith('filecoinwallet')) {
      var list = link.split('uri=');
      if (list.length == 2) {
        return list[1];
      } else {
        return '';
      }
    } else {
      return '';
    }
  }
}

String trParams(String tr, [Map<String, String> params = const {}]) {
  var trans = tr;
  if (params.isNotEmpty) {
    params.forEach((key, value) {
      trans = trans.replaceAll('@$key', value);
    });
  }
  return trans;
}

String StringTrim(String str){
  if(str.trim()==''){ return str; }
  var arr1 = str.split(' ');
  var arr2 =arr1.where((ele)=>ele!='');
  String  res =arr2.join(' ');
  return res;
}