part of 'home_bloc.dart';

class HomeState extends Equatable {
  final WCSession connectedSession;
  final WCMeta meta;
  final List<Token> tokenList;
  HomeState({
    this.connectedSession,
    this.meta,
    this.tokenList
  });

  @override
  List<Object> get props => [this.connectedSession,this.meta,this.tokenList];

  factory HomeState.idle() {
    return HomeState(
        connectedSession:null,
        meta:null,
        tokenList:[]
    );
  }

  HomeState copyWithHomeState({
    WCSession connectedSession,
    WCMeta meta,
    List<Token> tokenList
  }) {
    return HomeState(
      connectedSession: connectedSession ?? this.connectedSession,
      meta: meta ?? this.meta,
      tokenList:tokenList ?? this.tokenList
    );
  }
}
