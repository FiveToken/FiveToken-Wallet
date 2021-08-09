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
  Color c = CustomColor.bgGrey;
  String get label {
    return netType == 2 ? name : '$chain$net'.tr;
  }

  String getDetailLink(cid) {
    if (addressType == 'eth') {
      return '$browser/tx/$cid';
    } else {
      return '$browser/tipset/message-detail?cid=$cid';
    }
  }

  Network(
      {this.name = '',
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
      this.coin = ''});
  static Network get filecoinMainNet => Network(
      chain: 'filecoin',
      net: 'main',
      netType: 0,
      rpc: 'https://api.filscan.io:8700/rpc/v1',
      coin: 'FIL',
      browser: 'https://filscan.io',
      prefix: 'f',
      color: '0xff5CC1CB',
      path: "m/44'/461'/0'/0",
      addressType: 'filecoin');
  static Network get ethMainNet => Network(
      chain: 'eth',
      net: 'main',
      netType: 0,
      rpc: 'https://mainnet.infura.io/v3/96837d28a772466ca6ed88eddb221e09',
      chainId: '1',
      path: "m/44'/60'/0'/0",
      coin: 'ETH',
      color: '0xff29B6AF',
      addressType: 'eth');
  static Network get binanceMainNet => Network(
      chain: 'binance',
      net: 'main',
      netType: 0,
      rpc: 'https://bsc-dataseed1.ninicoin.io',
      coin: 'BNB',
      chainId: '56',
      path: "m/44'/60'/0'/0",
      addressType: 'eth');

  static Network get filecoinTestNet => Network(
      chain: 'filecoin',
      net: 'calibration',
      netType: 1,
      path: "m/44'/461'/0'/0",
      rpc: 'https://calibration.filscan.io:8800/rpc/v1',
      coin: 'FIL',
      prefix: 't',
      browser: 'https://calibration.filscan.io/#',
      addressType: 'filecoin');
  static Network get ethKovanNet => Network(
      chain: 'eth',
      net: 'kovan',
      netType: 1,
      path: "m/44'/60'/0'/0",
      rpc: 'https://kovan.infura.io/v3/96837d28a772466ca6ed88eddb221e09',
      coin: 'ETH',
      chainId: '42',
      color: '0xff9064FF',
      browser: 'https://kovan.etherscan.io/',
      addressType: 'eth');
  static Network get ethRopstenNet => Network(
      chain: 'eth',
      net: 'ropsten',
      path: "m/44'/60'/0'/0",
      netType: 1,
      rpc: 'https://ropsten.infura.io/v3/96837d28a772466ca6ed88eddb221e09',
      coin: 'ETH',
      chainId: '3',
      color: '0xffFF4A8D',
      browser: 'https://ropsten.etherscan.io/',
      addressType: 'eth');
  static Network get ethRinkebyNet => Network(
      chain: 'eth',
      net: 'rinkeby',
      netType: 1,
      chainId: '4',
      path: "m/44'/60'/0'/0",
      color: '0xffF6C343',
      rpc: 'https://rinkeby.infura.io/v3/96837d28a772466ca6ed88eddb221e09',
      coin: 'ETH',
      browser: 'https://rinkeby.etherscan.io/',
      addressType: 'eth');
  static Network get ethGoerliNet => Network(
      chain: 'eth',
      net: 'goerli',
      netType: 1,
      path: "m/44'/60'/0'/0",
      color: '0xff3099f2',
      rpc: 'https://goerli.infura.io/v3/96837d28a772466ca6ed88eddb221e09',
      coin: 'ETH',
      chainId: '5',
      browser: 'https://goerli.etherscan.io/',
      addressType: 'eth');
  static Network get binanceTestnet => Network(
      chain: 'binance',
      net: 'test',
      netType: 1,
      path: "m/44'/60'/0'/0",
      rpc: 'https://binancerpc.io',
      coin: 'BNB',
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
