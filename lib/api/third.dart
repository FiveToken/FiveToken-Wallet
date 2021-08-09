import 'package:fil/index.dart';
var apiMap = <String, String>{
  "dev": "http://192.168.19.56:9999",
  "test": "http://192.168.1.207:9999",
  "pro": "http://8.209.219.115:8090"
};
var mode = 'pro';
Future<FilPrice> getFilPrice() async {
  try {
    var url=apiMap[mode];
    var response = await Dio().get('$url/third/price');
    print(response);
    if (response.data['code'] == 0) {
      return FilPrice.fromJson(response.data['data']);
    } else {
      return FilPrice();
    }
  } catch (e) {
    print(e);
    return FilPrice();
  }
}