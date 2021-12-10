part of 'main_bloc.dart';

class MainState extends Equatable {
  final ChainWallet chainWallet;
  final bool hideTestnet;
  final List<List<Network>> filterNets;
  final String balance;

  MainState({
    this.chainWallet,
    this.hideTestnet,
    this.filterNets,
    this.balance,
  });

  factory MainState.idle() {
    bool bol = Global.store.getBool('hideTestnet') ?? false;
    List<List<Network>> nets = bol ? [Network.netList[0]] : Network.netList;
    return MainState(
      chainWallet: ChainWallet(),
      hideTestnet: bol,
      filterNets: nets,
      balance:'0',
    );
  }

  MainState copyWithMainState({
    ChainWallet chainWallet,
    bool hideTestnet,
    List<List<Network>> filterNets,
    String balance
  }) {
    return MainState(
      chainWallet: chainWallet ?? this.chainWallet,
      hideTestnet:hideTestnet ?? this.hideTestnet,
      filterNets:filterNets ?? this.filterNets,
      balance:balance ?? this.balance,
    );
  }

  MainState copyWithMainStateHideTestNet({
    hideTestnet,
    filterNets
  }) {
    return MainState(
      filterNets:filterNets,
      hideTestnet:hideTestnet,
    );
  }

  @override
  // TODO: implement props
  List<Object> get props => [this.chainWallet,this.filterNets,this.hideTestnet,this.balance];
}
