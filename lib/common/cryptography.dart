import 'dart:convert';
import 'package:cryptography/cryptography.dart';
Future<String> sha256hash(String str) async{
  final hash = await Sha256().hash(utf8.encode(str));
  return base64Encode(hash.bytes as List<int>);
}