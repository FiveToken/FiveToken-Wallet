part of 'home_bloc.dart';

class HomeState extends Equatable {
  final WCSession connectedSession;
  final WCMeta meta;
  final List<Token> tokenList;
  final String chainType;
  HomeState({
    this.connectedSession,
    this.meta,
    this.tokenList,
    this.chainType
  });

  @override
  List<Object> get props => [this.connectedSession,this.meta,this.tokenList,this.chainType];

  factory HomeState.idle() {
    return HomeState(
        connectedSession:null,
        meta:null,
        chainType:'',
        tokenList:[]
    );
  }

  HomeState copyWithHomeState({
    WCSession connectedSession,
    WCMeta meta,
    String chainType,
    List<Token> tokenList
  }) {
    return HomeState(
      connectedSession: connectedSession ?? this.connectedSession,
      meta: meta ?? this.meta,
      chainType:chainType ?? this.chainType,
      tokenList:tokenList ?? this.tokenList
    );
  }
}
