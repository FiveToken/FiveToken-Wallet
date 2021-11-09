part of 'main_bloc.dart';

// import 'package:equatable/equatable.dart';
class MainState extends Equatable {
  final Locale language;
  final String currency;
  final ChainWallet chainWallet;

  MainState({this.language, this.currency, this.chainWallet});

  factory MainState.idle() {
    return MainState(
      language: Locale('en'),
      currency: 'USD',
    );
  }

  MainState replaceWithLanguage({Locale language}) {
    return MainState(
      chainWallet: chainWallet,
      language: language,
      currency: currency,
    );
  }

  MainState replaceWithCurrency({String currency}) {
    return MainState(
      chainWallet: chainWallet,
      language: language,
      currency: currency,
    );
  }

  MainState copyWithChainWallet({ChainWallet chainWallet}) {
    return MainState(
      chainWallet: chainWallet,
      language: language,
      currency: currency,
    );
  }

  @override
  // TODO: implement props
  List<Object> get props => [this.language, this.currency];
}
