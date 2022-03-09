import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:fil/chain/net.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:fil/models/index.dart';
import 'package:fil/models/private.dart';
import 'package:fil/request/global.dart';
import 'package:fil/utils/decimal_extension.dart';
import 'package:fil/utils/string_extension.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:fil/utils/num_extension.dart';
import 'dart:async';
import 'package:convert/convert.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zxcvbn/zxcvbn.dart';
const psalt = "vFIzIawYOU";

/*
 encryption
 * @param {string} raw
 * @param {String} mix：key
*/
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

/*
 decrypt
 * @param {string} raw
 * @param {string} mix: key
*/
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


/*
 String copy
 * @param {string} text
 * @param {Function} callback
*/
void copyText(String text, {Function callback}) {
  var data = ClipboardData(text: text);
  Clipboard.setData(data).then((_) {
    if (callback != null) {
      callback();
    }
  });
}

/*
 String truncation
 * @param {string}
 * @param {int} start
 * @param {int} end
*/
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
/*
 Judge whether it is a number
 * @param {string} input
*/

bool isDecimal(String input) {
  var r = RegExp(r"(^\d+(?:\.\d+)?([eE]-?\d+)?$|^\.\d+([eE]-?\d+)?$)");
  if (r.hasMatch(input.trim())) {
    return true;
  }
  return false;
}

/*
  contract address inspection
  * @param {string} address:contract address
*/

bool isValidContractAddress(String address){
  var start = address.startsWith('0x');
  var reg = RegExp(r"([A-Fa-f0-9]$)");
  var valid = reg.hasMatch(address);
  return start && valid;
}

/*
  check address
  * @param {string} address:address
  * @param {Network} network:network to be verified
*/
bool isValidChainAddress(String address, Network network) {
  try{
    if(network.addressType == 'filecoin'){
      var valid = checkFileCoinAddress(address);
      return valid;
    }else{
      var start = address.startsWith('0x');
      var reg = RegExp(r"([A-Fa-f0-9]{40}$)");
      var valid = reg.hasMatch(address);
      return start && valid;
    }
  }catch(error){
    return false;
  }
}


/*
* Check address validity
* @param {string} address:address
* @returns {Boolean}
*/

bool checkFileCoinAddress (String address) {
  if (!address.isNotEmpty) return false;
  if (address.length < 3) return false;
  String network = address[0];
  if (network != 'f' && network != 't') return false;
  var map = {
    "ID": '0',
    "secP256K1": '1',
    "ACTOR": '2',
    "BLS": '3'
  };

  String protocol = address[1] as String;

  if (protocol == map['ID'] && address.length as int> 22) return false;

  if (protocol == map['secP256K1'] && address.length != 41) return false;

  if (protocol == map['ACTOR'] && address.length != 41) return false;

  if (protocol == map['BLS'] && address.length != 86) return false;

  return true;
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


/*
  balance formatting
  * @param {string} amount
  * @param {num} size:significant number of decimal places
  * @param {double} min:formatted minimum,If the balance is less than the minimum value, return the minimum value + ...
  * @param {int} precision: current formatted balance precision
*/
String formatCoin(String amount, { int size = 4, double min, int precision = 18 }) {
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
    return '0';
  }
}

/*
  get the minimum precision value
  * @param {string} fil
  * @param {int} precision: current value precision
*/
String getChainValue(String fil, {int precision = 18}) {
  try{
    var _value = Decimal.parse(fil) * Decimal.fromInt(pow(10, 18).toInt());
    var _amount = Decimal.parse(_value.toString()) * Decimal.fromInt(pow(10, precision).toInt())/Decimal.fromInt(pow(10,18).toInt());
    var _decimal = _amount.toString().toDecimal;
    var res = _decimal.fmtDown(0);
    var val = num.parse(res).toStringAsFixed(0);
    return val;
  }catch(error){
    return '0';
  }
}

/*
  ethereum private key verification
  * @param {string} str
*/
bool ethPrivate(String str){
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

/*
  open in browser
  * @param {string} url
*/
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

/*
  password verification
  * @param {string} pass
*/
bool isValidPass(String pass){
  pass = pass.trim();
  return pass.length > 11;
}

/*
  url check
  * @param {string} url
*/
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

/*
  walletConnect link verification
  * @param {string} link
*/
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

/*
  mnemonic string to list
  * @param {string} str
*/
String StringTrim(String str){
  if(str.trim()==''){ return str; }
  var arr1 = str.split(' ');
  var arr2 =arr1.where((ele)=>ele!='');
  String  res =arr2.join(' ');
  return res;
}
num zxcvbnLevel(String password){
  final zxcvbnFn = Zxcvbn();
  final result = zxcvbnFn.evaluate(password);
  return result.score as num;
}