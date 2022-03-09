import 'dart:convert';
import 'package:cryptography/cryptography.dart';

Future<String> genPrivateKeyDigest(String privateKey) async {
  final hash = await new Sha256().hash(base64Decode(privateKey));
  return base64Encode(hash.bytes.sublist(0, 16));
}