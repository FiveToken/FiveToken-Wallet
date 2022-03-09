part of 'add_bloc.dart';

class AddState extends Equatable {
  final List<List<Network>> network;
  const AddState({this.network});

  @override
  List<Object> get props => [network];

  factory AddState.idle(){
    final network = Network.netList;
    return const AddState(network: []);
  }

  AddState copy(List<List<Network>> network) {
    return AddState(
      network: network ?? this.network,
    );
  }

  List<List<Network>> get getNetwork {
    final list = [];
    list.addAll(network);
    list.addAll(OpenedBox.netInstance.values);
    return list as List<List<Network>>;
  }
}
