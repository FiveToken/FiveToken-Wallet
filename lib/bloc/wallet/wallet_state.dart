part of 'wallet_bloc.dart';

class WalletState extends Equatable {
  final String accountName;
  final String mid;
  final List storeMessageList;
  final bool enablePullUp;

  final int timestamp;

  @override
  // TODO: implement props
  List<Object> get props => [
    this.accountName,
    this.storeMessageList,
    this.timestamp
  ];

  WalletState(
      {this.accountName,
        this.mid,
        this.storeMessageList,
        this.enablePullUp,
        this.timestamp});

  factory WalletState.idle() {
    return WalletState(
        accountName: '',
        mid: '',
        storeMessageList: [],
        enablePullUp: true,
        timestamp:0
    );
  }

  WalletState copyWithWalletState({
    String accountName,
    String mid,
    List storeMessageList,
    bool enablePullUp,
    int timestamp
  }) {
    return WalletState(
        accountName: accountName ?? this.accountName,
        mid: mid ?? this.mid,
        storeMessageList: storeMessageList ?? this.storeMessageList,
        enablePullUp: enablePullUp ?? this.enablePullUp,
        timestamp:timestamp
    );
  }

  Map<String, List<CacheMessage>> get formatMessageList {
    Map<String, List<CacheMessage>> messageMap = {};
    final list = [];
    String formatStr = 'YYYY-MM-DD';
    list.addAll(storeMessageList);
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

