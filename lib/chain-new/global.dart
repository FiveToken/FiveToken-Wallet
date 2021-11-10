
import 'package:fil/chain-new/provider.dart';
import 'package:fil/chain-new/ether.dart';
import 'package:fil/chain-new/filecoin.dart';
import 'package:fil/common/global.dart';
import 'package:fil/models-new/rpc_network.dart';

class Chain {
  static ChainProvider get chainProvider =>
      Chain()._chainProvider;

  ChainProvider _chainProvider;

  static Chain _instance;

  factory Chain() {
    return _instance ??= Chain._().._init();
  }

  Chain._();

  _init() {
    String chainRpc = Global.store.getString('chainRpc');
    String chainType = Global.store.getString('chainType');
    switch(chainType){
      case 'filecoin':
        this._chainProvider = Filecoin(chainRpc);
        break;
      case 'eth':
        this._chainProvider = Ether(chainRpc);
        break;
      default:
        this._chainProvider = Filecoin(chainRpc);
    }
  }

  static setRpcNetwork(chainRpc,chainType) {
    Global.store.setString('chainRpc', chainRpc);
    Global.store.setString('chainType', chainType);
    switch(chainType){
      case 'filecoin':
        Chain()._chainProvider = Filecoin(RpcNetwork.filecoinMainNet.rpc);
        break;
      case 'eth':
        Chain()._chainProvider = Ether(RpcNetwork.ethMainNet.rpc);
        break;
      default:
        Chain()._chainProvider = Filecoin(RpcNetwork.filecoinMainNet.rpc);
    }
  }
}