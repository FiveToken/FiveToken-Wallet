import 'package:fil/index.dart';

Future<CoinPrice> getFilPrice(String chain) async {
  try {
    Map<String, String> coinMap = {
      'filecoin': 'filecoin',
      'eth': 'ethereum',
      'binance': 'binancecoin'
    };
    var url = "http://8.209.219.115:8090";
    var coin=coinMap[chain];
    var response = await Dio().get('$url/third/priceByType?coin=$coin');
    print(response);
    if (response.data['code'] == 0) {
      return CoinPrice.fromJson(response.data['data']);
    } else {
      return CoinPrice();
    }
  } catch (e) {
    print(e);
    return CoinPrice();
  }
}
