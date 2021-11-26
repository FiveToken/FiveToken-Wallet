import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/request/global.dart';
import 'package:fil/index.dart';
import 'package:fil/store/store.dart'; // $store
import 'package:fil/init/hive.dart'; // OpenedBox
import 'package:web3dart/web3dart.dart'; // TransactionReceipt

part 'wallet_state.dart';
part 'wallet_event.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletState.idle()) {
    /*
        When the current network is fileCoin, the list data is local data,
        and the interface returns the linked data (removing and local duplicate data).
        When the current network is eth, the list data is local data
    */
    on<GetMessageListEvent>((event, emit) async {
      if(event.chainType == 'filecoin'){
        add(GetStoreMessageListEvent(event.rpc, event.chainType));
        add(UpdateFileCoinPendingStateEvent(event.rpc,event.chainType,event.actor,event.direction));
      }else{
        add(GetStoreMessageListEvent(event.rpc, event.chainType));
        add(UpdateEthMessageListStateEvent(event.rpc, event.chainType));
      }
    });

    on<GetStoreMessageListEvent>((event,emit){
      List list = getStoreMsgList();
      emit(state.copyWithWalletState(storeMessageList: list ));
    });

    on<GetFileCoinMessageListEvent>((event, emit) async{
      String mid = state.mid ?? '';
      Chain.setRpcNetwork(event.rpc, event.chainType);
      var result = await Chain.chainProvider.getFileCoinMessageList(
          actor: event.actor,
          direction: event.direction,
          mid: mid
      );
      var box = OpenedBox.mesInstance;
      List<CacheMessage> messages = [];
      result.forEach((map) {
        var mes = CacheMessage(
            hash: map['cid'],
            to: map['to'],
            from: map['from'],
            value: map['value'],
            blockTime: map['block_time'],
            exitCode: map['exit_code'],
            owner: $store.wal.addr,
            pending: 0,
            rpc: $store.net.rpc,
            height: map['block_epoch'],
            fee: map['gas_fee'],
            mid: map['mid'],
            nonce: map['nonce']);
        messages.add(mes);
      });
      messages.toList();
      List midList = messages.where((mes) => mes.mid != '').toList();
      String lastMid = midList.last.mid;
      emit(state.copyWithWalletState(interfaceMessageList: messages,mid:lastMid ,enablePullUp:result.length >= 10 ));
    });

    on<UpdateFileCoinPendingStateEvent>((event,emit) async{
      try{
        List pendingList = state.storeMessageList;
        if(pendingList.length > 0){
          var box = OpenedBox.mesInstance;
          Chain.setRpcNetwork(event.rpc, event.chainType);
          List param = [];
          state.storeMessageList.forEach((n) async {
            param.add({"from":n.from,"nonce":n.nonce});
          });
          // Get the status of the local store pending message
          var result = await Chain.chainProvider.getMessagePendingState(param);
          result.forEach((n) {
            var message = n['message'];
            if(message.isNotEmpty){
              state.storeMessageList.forEach((m) {
                // Filter the same message returned by local store and interface
                if((message["from"] == m.from) && (message["nonce"] == m.nonce)){
                  // If the hash is the same, judge whether the message is successfully chained according to the code，
                  // If the hash are different, the message sending fails. Delete the local store record of this message and get the list returned by the interface
                  // exit_code == 0 ? "success":"fail"
                  if(message["cid"] == m.hash ){
                    var mes = CacheMessage(
                        hash: message["cid"],
                        to: message['to'],
                        from: message['from'],
                        value: message['value'],
                        blockTime: message['block_time'],
                        exitCode: message['exit_code'],
                        owner: message['from'],
                        pending: 0,
                        rpc: m.rpc,
                        height: message['block_epoch'],
                        fee: message['gas_fee'],
                        mid: message['mid'],
                        nonce: message['nonce']
                    );
                    box.put(n["message"]["cid"],mes);
                  }else{
                    box.delete(m.hash);
                  }
                }
              });
            }
          });
          add(GetFileCoinMessageListEvent(event.rpc,event.chainType,event.actor,event.direction));
          List storeList = getStoreMsgList();
          emit(state.copyWithWalletState(storeMessageList: storeList ));
        }else{
          add(GetFileCoinMessageListEvent(event.rpc,event.chainType,event.actor,event.direction));
        }
      }catch(error){
        debugPrint("error");
      }
    });

    on<UpdateEthMessageListStateEvent>((event, emit) async{
      try{
        List pendingList = state.storeMessageList;
        if(pendingList.length > 0){
          Chain.setRpcNetwork(event.rpc, event.chainType);
          var box = OpenedBox.mesInstance;

          var list = await Future.wait(
              pendingList.map((mes) => Chain.chainProvider.getTransactionReceipt(mes.hash)));
          list = list.where((r) => r != null).toList();
          Map<String, TransactionReceipt> map = {};
          for (var i = 0; i < list.length; i++) {
            var t = list[i];
            var mes = pendingList[i];
            if (t != null && t.gasUsed != null) {
              var limit = BigInt.tryParse(mes.gas.gasPrice) ?? BigInt.one;
              mes.fee = (limit * t.gasUsed).toString();
              map[mes.hash] = t;
            }
          }
          if (map.isNotEmpty) {
            Chain.setRpcNetwork($store.net.rpc, $store.net.chain);
            var futures = map.values
                .map((t) =>
                Chain.chainProvider.getBlockByNumber(t.blockNumber.blockNum))
                .toList();
            var mesList = map.keys.toList();
            var blocks = await Future.wait(futures);
            for (var i = 0; i < mesList.length; i++) {
              var block = blocks[i];
              var key = mesList[i];
              var mes = box.get(key);
              if (block.timestamp != null && block.timestamp is int) {
                mes.pending = 0;
                mes.blockTime = block.timestamp;
                mes.height = block.number;
                mes.exitCode = map[key].status ? 0 : 1;
                box.put(key, mes);
              }
            }
          }
          List storeList = getStoreMsgList();
          emit(state.copyWithWalletState(storeMessageList: storeList ));
        }
      }catch(error){
        debugPrint("error");
      }
    });

    on<SetEnablePullUpEvent>((event,emit){
      emit(state.copyWithWalletState(enablePullUp:event.enablePullUp));
    });

  }
}

List getStoreMsgList(){
  var list = <CacheMessage>[];
  var address = $store.wal.addr;
  var box = OpenedBox.mesInstance;
  box.values.forEach((message) {
    if (
      (message.from == address || message.to == address)
      &&  message.rpc == $store.net.rpc
    ) {
      list.add(message);
    }
  });
  list.sort((a, b) {
    if (a.blockTime != null && b.blockTime != null) {
      return b.blockTime.compareTo(a.blockTime);
    } else {
      return 1;
    }
  });
  return list ?? [];
}