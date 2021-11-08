class RpcNetwork {
  RpcNetwork({
    this.name,
    this.chain,
    this.net,
    this.chainId,
    this.rpc,
    this.browser,
    this.coin,
    this.netType,
    this.addressType,
    this.prefix,
    this.path,
    this.color,});

  RpcNetwork.fromJson(dynamic json) {
    name = json['name'];
    chain = json['chain'];
    net = json['net'];
    chainId = json['chainId'];
    rpc = json['rpc'];
    browser = json['browser'];
    coin = json['coin'];
    netType = json['netType'];
    addressType = json['addressType'];
    prefix = json['prefix'];
    path = json['path'];
    color = json['color'];
  }
  String name;
  String chain;
  String net;
  String chainId;
  String rpc;
  String browser;
  String coin;
  int netType;
  String addressType;
  String prefix;
  String path;
  String color;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['chain'] = chain;
    map['net'] = net;
    map['chainId'] = chainId;
    map['rpc'] = rpc;
    map['browser'] = browser;
    map['coin'] = coin;
    map['netType'] = netType;
    map['addressType'] = addressType;
    map['prefix'] = prefix;
    map['path'] = path;
    map['color'] = color;
    return map;
  }

  static RpcNetwork get ethMainNet => RpcNetwork(
      chain: 'eth',
      net: 'main',
      netType: 0,
      rpc: 'https://mainnet.infura.io/v3/',
      chainId: '1',
      path: "m/44'/60'/0'/0",
      coin: 'ETH',
      browser: 'https://etherscan.io',
      color: '0xff29B6AF',
      addressType: 'eth');
  static RpcNetwork get binanceMainNet => RpcNetwork(
      chain: 'binance',
      net: 'main',
      netType: 0,
      rpc: 'https://bsc-dataseed1.ninicoin.io',
      coin: 'BNB',
      browser: 'https://bscscan.com',
      chainId: '56',
      path: "m/44'/60'/0'/0",
      addressType: 'eth');

  static RpcNetwork get filecoinMainNet => RpcNetwork(
      chain: 'filecoin',
      net: 'main',
      netType: 0,
      rpc: 'https://api.fivetoken.io',
      coin: 'FIL',
      browser: 'https://filscan.io',
      prefix: 'f',
      color: '0xff5CC1CB',
      path: "m/44'/461'/0'/0",
      addressType: 'filecoin');

}