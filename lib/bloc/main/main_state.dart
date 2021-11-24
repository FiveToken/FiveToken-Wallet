part of 'main_bloc.dart';

class MainState extends Equatable {
  final Locale language;
  final String currency;
  final ChainWallet chainWallet;
  final bool hideTestnet;
  final List<List<Network>> filterNets;
  final String balance;

  MainState({
    this.language,
    this.currency,
    this.chainWallet,
    this.hideTestnet,
    this.filterNets,
    this.balance,
  });

  factory MainState.idle() {
    bool bol = Global.store.getBool('hideTestnet') ?? false;
    List<List<Network>> nets = bol ? [Network.netList[0]] : Network.netList;
    return MainState(
      language: Locale('en'),
      currency: 'USD',
      chainWallet: ChainWallet(),
      hideTestnet: bol,
      filterNets: nets,
      balance:'0',
    );
  }

  MainState copyWithMainState({
    Locale language,
    ChainWallet chainWallet,
    String currency,
    bool hideTestnet,
    List<List<Network>> filterNets,
    String balance
  }) {
    return MainState(
      chainWallet: chainWallet ?? this.chainWallet,
      language: language ?? this.language,
      currency: currency ?? this.currency,
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
      chainWallet: chainWallet,
      language: language,
      currency: currency,
      filterNets:filterNets,
      hideTestnet:hideTestnet,
    );
  }

  @override
  // TODO: implement props
  List<Object> get props => [this.language, this.currency,this.chainWallet,this.filterNets,this.hideTestnet,this.balance];
}
