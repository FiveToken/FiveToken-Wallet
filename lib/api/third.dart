import 'package:fil/index.dart';

/// get fil price
Future<FilPrice> getFilPrice() async {
  try {
    var url='http://8.209.219.115:8090';
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