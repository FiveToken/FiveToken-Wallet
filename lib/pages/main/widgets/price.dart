import 'package:fil/index.dart';

class CoinPriceWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CoinPriceState();
  }
}

class CoinPriceState extends State<CoinPriceWidget> {
  CoinPrice price = CoinPrice();
  Worker worker;
  String marketPrice = '';
  @override
  void initState() {
    super.initState();
    if ($store.net.chain != '') {
      getPrice();
    }
    worker = ever($store.network, (Network net) {
      if (net.hasPrice) {
        setState(() {
          marketPrice = '';
        });
        getPrice();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    worker.dispose();
  }

  double get rate {
    var lang = Global.langCode;
    lang = 'en';
    return lang == 'en' ? price.usd : price.cny;
  }

  // String get marketPrice {
  //   return getMarketPrice($store.wal.balance, rate);
  // }

  void getPrice() async {
    var res = await getFilPrice($store.net.chain);
    Global.price = res;
    if (res.cny != 0) {
      setState(() {
        price = res;
        marketPrice = getMarketPrice($store.wal.balance, rate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Visibility(
          child: CommonText(
            marketPrice,
            size: 30,
            weight: FontWeight.w800,
          ),
          visible: $store.net.hasPrice,
        ));
  }
}

String getMarketPrice(String balance, double rate) {
  try {
    var b = double.parse(balance) / pow(10, 18);
    //var code=Global.langCode;
    var code = 'en';
    var unit = code == 'en' ? '\$' : '¥';
    return rate == 0
        ? ''
        : ' $unit ${formatDouble((rate * b).toStringAsFixed(2))}';
  } catch (e) {
    return '';
  }
}
