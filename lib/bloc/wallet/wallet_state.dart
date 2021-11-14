part of 'wallet_bloc.dart';

class WalletState extends Equatable {
  final String accountName;
  final String mid;
  final List storeMessageList;
  final List interfaceMessageList;

  @override
  // TODO: implement props
  List<Object> get props =>
      [this.accountName, this.storeMessageList, this.interfaceMessageList];

  WalletState({
    this.accountName,
    this.mid,
    this.storeMessageList,
    this.interfaceMessageList,
  });

  factory WalletState.idle() {
    return WalletState(
        accountName: '',
        mid:'',
        storeMessageList: [],
        interfaceMessageList: [],
    );
  }

  WalletState copyWithWalletState({
   String accountName,
    String mid,
    List storeMessageList,
    List interfaceMessageList,
  }) {
    return WalletState(
        accountName: accountName ?? this.accountName,
        mid:mid ?? this.mid,
        storeMessageList: storeMessageList ?? this.storeMessageList,
        interfaceMessageList: interfaceMessageList ?? this.interfaceMessageList,
    );
  }

  Map<String, List<CacheMessage>> get formatMessageList{
    Map<String, List<CacheMessage>> messageMap = {};
    final list = [];
    String formatStr = 'YYYY-MM-DD';
    list.addAll(storeMessageList);
    list.addAll(interfaceMessageList);
    list.forEach((mes) {
      var time = formatTimeByStr(mes.blockTime, str: formatStr);
      var item = messageMap[time];
      if (item == null) {
        messageMap[time] = [];
      }
      messageMap[time].add(mes);
    });
    return messageMap;
  }


}

// class WalletInitial extends WalletState {
//
//   @override
//   List<Object> get props => [];
// }
