import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:connectivity/connectivity.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

const psalt = "vFIzIawYOU";
Future<bool> checkNetStatus() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  bool isOn = connectivityResult != ConnectivityResult.none;
  return isOn;
}

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

String parseE(String str) {
  final isE = RegExp(r"[eE][+-]\d+$");
  if (!isE.hasMatch(str)) {
    return str;
  }
  str = str.toLowerCase();
  var parts = str.split('e');
  var n = parts[0];
  var p = parts[1];
  var sign = p[0];
  var len = int.parse(p.substring(1)); //Number(p.slice(1))
  var r = "";
  if (sign == '+') {
    r = "1";
    for (var i = 0; i < len; i++) {
      r += "0";
    }
    n = n.replaceAll('.', '');
    r = n + r.substring(n.length);
  } else {
    r = "0.";
    for (var i = 0; i < len; i++) {
      r += "0";
    }
    n = n.replaceFirst('0', '');
    n = n.replaceFirst('.', '');
    r = r.substring(0, r.length - 1) + n;
  }
  return r;
}

String toFixed(double input, int len) {
  var r = input.toStringAsFixed(len).replaceFirst(RegExp(r"0+$"), "");
  r = r.replaceFirst(RegExp(r"\.$"), "");
  return parseE(r);
}

bool isDecimal(String input) {
  var r = RegExp(r"(^\d+(?:\.\d+)?([eE]-?\d+)?$|^\.\d+([eE]-?\d+)?$)");
  if (r.hasMatch(input.trim())) {
    return true;
  }
  return false;
}

bool isValidAddress(String input) {
  var addr = input.trim().toLowerCase();
  if (addr == '') {
    return false;
  }
  var mainNet = addr[0];
  if (mainNet != 't' && mainNet != 'f') {
    return false;
  }
  var protocol = addr[1];
  if (!RegExp(r"^0|1|3$").hasMatch(protocol)) {
    return false;
  }
  var raw = addr.substring(2);
  if (protocol == "0") {
    if (raw.length > 20) {
      return false;
    }
  }
  if (protocol == "3") {
    if (raw.length < 30 || raw.length > 120) {
      return false;
    }
  }
  return true;
}

bool isValidChainAddress(String addr, Network net) {
  return net.addressType == 'eth'
      ? isValidEthAddress(addr)
      : isValidFilecoinAddress(addr, net);
}

bool isValidEthAddress(String addr) {
  return addr.length == 42 && addr.substring(0, 2) == '0x';
}

bool isValidFilecoinAddress(String address, Network net) {
  var prefix = net.prefix;
  if (address[0] != prefix) {
    return false;
  }
  var addr = address.trim().toLowerCase();
  if (addr == '') {
    return false;
  }
  var protocol = addr[1];
  if (!RegExp(r"^0|1|3$").hasMatch(protocol)) {
    return false;
  }
  var raw = addr.substring(2);
  if (protocol == "0") {
    if (raw.length > 20) {
      return false;
    }
  }
  if (protocol == "3") {
    if (raw.length < 30 || raw.length > 120) {
      return false;
    }
  }
  return true;
}

List<String> parseFee(double fee) {
  if (fee == 0) {
    return ['0', '1000'];
  } else if (fee < 0.0000001) {
    return ['1000', (fee * pow(10, 15)).toStringAsFixed(0)];
  } else {
    return [(fee * pow(10, 10)).toStringAsFixed(0), '99999999'];
  }
}

String genCKBase64(String mne) {
  var seed = bip39.mnemonicToSeed(mne);
  bip32.BIP32 nodeFromSeed = bip32.BIP32.fromSeed(seed);
  var rs = nodeFromSeed.derivePath("m/44'/461'/0'/0");
  var rs0 = rs.derive(0);
  var ck = base64Encode(rs0.privateKey);
  return ck;
}

String genRandStr(int size) {
  String str = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  String result = "";
  var strLen = str.length;
  for (int i = 0; i < size; i++) {
    result += str[Random().nextInt(strLen)];
  }
  return result;
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

String fixedFloat({String number, num size = 2}) {
  var arr = number.split('.');
  var intStr = arr[0];
  var dotStr = arr[1];
  if (dotStr != null) {
    return (double.parse(intStr) + double.parse('0.$dotStr').toPrecision(size))
        .toString();
  } else {
    return number;
  }
}

String formatFil({double attoFil, num size = 5}) {
  var str = attoFil.toString().split('.')[0];
  num length = str.length;
  if (length < 5) {
    return '$str attoFil';
  } else if (length >= 5 && length <= 13) {
    return '${(attoFil / pow(10, 9)).toPrecision(size)} nanoFil';
  } else {
    return '${(attoFil / pow(10, 18)).toPrecision(size)} Fil';
  }
}

String truncate(double value, {int size = 4}) {
  return ((value * pow(10, size)).floor() / pow(10, size)).toString();
}

String formatFIL(String attoFil, {num size = 4, bool fixed = false}) {
  if (attoFil == '0') {
    return '0 FIL';
  }
  try {
    var str = attoFil;
    var v = BigInt.parse(attoFil);
    num length = str.length;
    if (length < 5) {
      return '$str attoFIL';
    } else if (length >= 5 && length <= 13) {
      var unit = BigInt.from(pow(10, 9));
      var res = v / unit;
      return fixed
          ? '${res.toStringAsFixed(size)} nanoFIL'
          : '${truncate(res)} nanoFIL';
    } else {
      var unit = BigInt.from(pow(10, 18));
      var res = v / unit;
      return fixed
          ? '${res.toStringAsFixed(size)} FIL'
          : '${truncate(res, size: size)} FIL';
    }
  } catch (e) {
    return attoFil;
  }
}

String formatCoin(String amount,
    {num size = 4, bool fixed = false, Network net}) {
      net = net ?? $store.net;
  if (amount == '0') {
    return '0 ${net.coin}';
  }
  
  var isFil = net.addressType == AddressType.filecoin.type;
  try {
    var str = amount;
    var v = BigInt.parse(amount);
    num length = str.length;
    if (length < 5) {
      var u = isFil ? 'attoFIL' : 'wei';
      return '$str $u';
    } else if (length >= 5 && length <= 13) {
      var u = isFil ? 'nanoFIL' : 'gwei';
      var unit = BigInt.from(pow(10, 9));
      var res = v / unit;
      return fixed
          ? '${res.toStringAsFixed(size)} $u'
          : '${truncate(res)} $u';
    } else {
      var u = isFil ? 'FIL' : net.coin;
      var unit = BigInt.from(pow(10, 18));
      var res = v / unit;
      return fixed
          ? '${res.toStringAsFixed(size)} $u'
          : '${truncate(res, size: size)} $u';
    }
  } catch (e) {
    return amount;
  }
}

String fil2Atto(String fil) {
  //return parseE((double.parse(fil) * pow(10, 18)).toString()).split('.')[0];
  return (BigInt.from((double.parse(fil) * pow(10, 9))) *
          BigInt.from(pow(10, 9)))
      .toString();
}

String getChainValue(String fil, {int precision = 18}) {
  if (precision < 10) {
    return BigInt.from((double.parse(fil) * pow(10, precision))).toString();
  }
  return (BigInt.from((double.parse(fil) * pow(10, 9))) *
          BigInt.from(pow(10, 9)))
      .toString();
}

String atto2Fil(String value, {num len = 6}) {
  return Fil(attofil: value).toFixed(len: len);
}

String encodeString(String str, [int times = 1]) {
  List<int> s = utf8.encode(str);
  return base64Encode(s);
}

String decodeString(String str) {
  return utf8.decode(base64Decode(str));
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

String getMaxFee(ChainGas gas) {
  var feeCap = gas.gasPrice;
  var gasLimit = gas.gasLimit;
  return formatFil(attoFil: (double.parse(feeCap) * gasLimit));
}
