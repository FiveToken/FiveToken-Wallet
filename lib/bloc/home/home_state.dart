part of 'home_bloc.dart';

class HomeState extends Equatable {
  final List<Token> tokenList;
  final String chainType;
  HomeState({
    this.tokenList,
    this.chainType
  });

  @override
  List<Object> get props => [this.tokenList,this.chainType];

  factory HomeState.idle() {
    return HomeState(
        chainType:'',
        tokenList:[]
    );
  }

  HomeState copyWithHomeState({
    String chainType,
    List<Token> tokenList
  }) {
    return HomeState(
      chainType:chainType ?? this.chainType,
      tokenList:tokenList ?? this.tokenList
    );
  }
}
