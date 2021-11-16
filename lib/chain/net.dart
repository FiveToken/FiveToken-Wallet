import 'package:fil/index.dart';
part 'net.g.dart';

@HiveType(typeId: 7)
class Network {
  @HiveField(0)
  String name;
  @HiveField(1)
  String chain;
  @HiveField(2)
  String net;
  @HiveField(3)
  String chainId;
  @HiveField(4)
  String rpc;
  @HiveField(5)
  String browser;
  @HiveField(6)
  String coin;
  @HiveField(7)
  int netType; // 0 main 1 test 2 custom
  @HiveField(8)
  String addressType;
  @HiveField(9)
  String prefix;
  @HiveField(10)
  String path;
  @HiveField(11)
  String color;
  @HiveField(12)
  int decimals;
  
  Color c = CustomColor.bgGrey;
  String get label {
    return netType == 2 ? name : '$chain$net'.tr;
  }

  String get url {
    return chain == 'eth' ? (rpc + EthClientID) : rpc;
  }

  String getDetailLink(String cid) {
    if (addressType == 'eth') {
      return '$browser/tx/$cid';
    } else {
      return '$browser/tipset/message-detail?cid=$cid';
    }
  }

  String getAddrDetailLink(String addr) {
    if (addressType == 'eth') {
      return '$browser/address/$addr';
    } else {
      return '$browser/tipset/address-detail?address=$addr';
    }
  }

  bool get hasPrice =>
      ['filecoin', 'eth', 'binance'].contains(chain) ||
      ['bnb', 'eth'].contains(coin.toLowerCase());
  static List<String> get labels =>
      ['mainNet'.tr, 'testNet'.tr, 'customNet'.tr];
  Network(
      {
        this.name = '',
      this.chain = '',
      this.net = '',
      this.netType = 0,
      this.chainId = '',
      this.rpc = '',
      this.browser = '',
      this.addressType = '',
      this.prefix = '',
      this.path = '',
      this.color = '0xffB4B5B7',
      this.coin = '',
        this.decimals = 0,
      });
  Network.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    chain = json['chain'];
    net = json['net'];
    netType = json['netType'];
    chainId = json['chainId'];
    rpc = json['rpc'];
    browser = json['browser'];
    addressType = json['addressType'];
    prefix = json['prefix'];
    path = json['path'];
    color = json['color'];
    coin = json['coin'];
    decimals = json['decimals'];
  }

  static Network get filecoinMainNet => Network(
      chain: 'filecoin',
      net: 'main',
      netType: 0,
      rpc: 'https://api.fivetoken.io',
      coin: 'FIL',
      browser: 'https://filscan.io',
      prefix: 'f',
      color: '0xff5CC1CB',
      path: "m/44'/461'/0'/0",
      decimals:18,
      addressType: 'filecoin');
  static Network get ethMainNet => Network(
      chain: 'eth',
      net: 'main',
      netType: 0,
      rpc: 'https://mainnet.infura.io/v3/',
      chainId: '1',
      path: "m/44'/60'/0'/0",
      coin: 'ETH',
      browser: 'https://etherscan.io',
      color: '0xff29B6AF',
      decimals:18,
      addressType: 'eth');
  static Network get binanceMainNet => Network(
      chain: 'binance',
      net: 'main',
      netType: 0,
      rpc: 'https://bsc-dataseed1.ninicoin.io',
      coin: 'BNB',
      browser: 'https://bscscan.com',
      chainId: '56',
      path: "m/44'/60'/0'/0",
      decimals:18,
      addressType: 'eth');

  static Network get filecoinTestNet => Network(
      chain: 'filecoin',
      net: 'calibration',
      netType: 1,
      path: "m/44'/461'/0'/0",
      rpc: 'https://api.calibration.fivetoken.io',
      coin: 'FIL',
      prefix: 't',
      browser: 'https://calibration.filscan.io',
      decimals:18,
      addressType: 'filecoin');
  static Network get ethKovanNet => Network(
      chain: 'eth',
      net: 'kovan',
      netType: 1,
      path: "m/44'/60'/0'/0",
      rpc: 'https://kovan.infura.io/v3/',
      coin: 'ETH',
      chainId: '42',
      color: '0xff9064FF',
      browser: 'https://kovan.etherscan.io',
      decimals:18,
      addressType: 'eth');
  static Network get ethRopstenNet => Network(
      chain: 'eth',
      net: 'ropsten',
      path: "m/44'/60'/0'/0",
      netType: 1,
      rpc: 'https://ropsten.infura.io/v3/',
      coin: 'ETH',
      chainId: '3',
      color: '0xffFF4A8D',
      browser: 'https://ropsten.etherscan.io',
      decimals:18,
      addressType: 'eth');
  static Network get ethRinkebyNet => Network(
      chain: 'eth',
      net: 'rinkeby',
      netType: 1,
      chainId: '4',
      path: "m/44'/60'/0'/0",
      color: '0xffF6C343',
      rpc: 'https://rinkeby.infura.io/v3/',
      coin: 'ETH',
      browser: 'https://rinkeby.etherscan.io',
      decimals:18,
      addressType: 'eth');
  static Network get ethGoerliNet => Network(
      chain: 'eth',
      net: 'goerli',
      netType: 1,
      path: "m/44'/60'/0'/0",
      color: '0xff3099f2',
      rpc: 'https://goerli.infura.io/v3/',
      coin: 'ETH',
      chainId: '5',
      browser: 'https://goerli.etherscan.io',
      decimals:18,
      addressType: 'eth');
  static Network get binanceTestnet => Network(
      chain: 'binance',
      net: 'test',
      netType: 1,
      path: "m/44'/60'/0'/0",
      rpc: 'https://data-seed-prebsc-1-s2.binance.org:8545',
      coin: 'BNB',
      browser: 'https://testnet.bscscan.com',
      chainId: '97',
      decimals:18,
      addressType: 'eth');
  static List<Network> get supportNets {
    return [
      Network.filecoinMainNet,
      Network.ethMainNet,
      Network.binanceMainNet,
      Network.filecoinTestNet,
      Network.ethKovanNet,
      Network.ethRinkebyNet,
      Network.ethRopstenNet,
      Network.ethGoerliNet,
      Network.binanceTestnet
    ];
  }

  static List<List<Network>> get netList {
    var custom = OpenedBox.netInstance.values.toList();
    return [
      [
        Network.filecoinMainNet,
        Network.ethMainNet,
        Network.binanceMainNet,
      ],
      [
        Network.filecoinTestNet,
        Network.ethKovanNet,
        Network.ethRinkebyNet,
        Network.ethRopstenNet,
        Network.ethGoerliNet,
        Network.binanceTestnet
      ],
      custom
    ];
  }

  static Network getNetByRpc(String rpc) {
    var nets = Network.supportNets.where((net) => net.rpc == rpc).toList();
    if (nets.isNotEmpty) {
      return nets[0];
    } else {
      var custom = OpenedBox.netInstance.get(rpc);
      return custom ?? Network();
    }
  }
}

class AddressType {
  String type;
  AddressType({this.type});
  static AddressType get filecoin => AddressType(type: 'filecoin');
  static AddressType get eth => AddressType(type: 'eth');
  static List<AddressType> get supportTypes =>
      [AddressType.filecoin, AddressType.eth];
}

