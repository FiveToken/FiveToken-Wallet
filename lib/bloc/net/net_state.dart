part of 'net_bloc.dart';

class NetState extends Equatable {
  final List<List<Network>> network;
  const NetState({this.network});

  @override
  List<Object> get props => [network];

  factory NetState.idle(){
    return const NetState(network: []);
  }

  NetState copy(List<List<Network>> network) {
    return NetState(
      network: network ?? this.network,
    );
  }

  List<List<Network>> get getNetwork {
    final list = [];
    list.addAll(network);
    list.addAll(OpenedBox.netInstance.values);
    return list;
  }
}
