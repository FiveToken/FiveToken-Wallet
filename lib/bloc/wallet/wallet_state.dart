part of 'wallet_bloc.dart';

class WalletState extends Equatable {
  final String accountName;
  final String mid;
  final List storeMessageList;
  final List interfaceMessageList;
  final bool enablePullUp;

  @override
  // TODO: implement props
  List<Object> get props =>
      [this.accountName, this.storeMessageList, this.interfaceMessageList];

  WalletState(
      {this.accountName,
      this.mid,
      this.storeMessageList,
      this.interfaceMessageList,
      this.enablePullUp});

  factory WalletState.idle() {
    return WalletState(
      accountName: '',
      mid: '',
      storeMessageList: [],
      interfaceMessageList: [],
      enablePullUp: true,
    );
  }

  WalletState copyWithWalletState({
    String accountName,
    String mid,
    List storeMessageList,
    List interfaceMessageList,
    bool enablePullUp,
  }) {
    final one = [];
    one.addAll(this.interfaceMessageList);
    one.addAll(interfaceMessageList ?? []);

    return WalletState(
        accountName: accountName ?? this.accountName,
        mid: mid ?? this.mid,
        storeMessageList: storeMessageList ?? this.storeMessageList,
        interfaceMessageList: one,
        enablePullUp: enablePullUp ?? this.enablePullUp);
  }

  Map<String, List<CacheMessage>> get formatMessageList {
    Map<String, List<CacheMessage>> messageMap = {};
    final list = [];
    String formatStr = 'YYYY-MM-DD';
    list.addAll(storeMessageList);
    list.addAll(interfaceMessageList);
    print('list');
    list.sort((a, b) {
      if (a.blockTime != null && b.blockTime != null) {
        return b.blockTime.compareTo(a.blockTime);
      } else {
        return 1;
      }
    });

    list.forEach((mes) {
      var time = formatTimeByStr(mes.blockTime, str: formatStr);
      var item = messageMap[time];
      if (item == null) {
        messageMap[time] = [];
      }
      messageMap[time].add(mes);
    });
    print('res');
    return messageMap;
  }
}

// class WalletInitial extends WalletState {
//
//   @override
//   List<Object> get props => [];
// }
