

import 'package:dio/dio.dart';
import 'package:fil/models/wallet.dart';

var defaultClient = Dio();
const ThirdPath = 'http://8.209.219.115:8090/third/priceByType?coin=';
Future<CoinPrice> getFilPrice(String chain, {Dio client}) async {
  if (client == null) {
    client = defaultClient;
  }
  try {
    Map<String, String> coinMap = {
      'filecoin': 'filecoin',
      'eth': 'ethereum',
      'binance': 'binancecoin'
    };

    var coin = coinMap[chain];
    var url = ThirdPath + coin;
    var response = await client.get(url);
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
