import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:day/day.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain-new/global.dart';
import 'package:fil/index.dart';
import 'package:fil/models-new/message_pending.dart';
import 'package:fil/store/store.dart'; // $store
import 'package:fil/init/hive.dart'; // OpenedBox
import 'package:web3dart/web3dart.dart'; // TransactionReceipt

part 'wallet_state.dart';
part 'wallet_event.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc() : super(WalletState.idle()) {
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

      // for (var i = 0; i < messages.length; i++) {
      //   var m = messages[i];
      //   await box.put(m.hash, m);
      // }
      messages.toList();

      List midList = messages.where((mes) => mes.mid != '').toList();
      String lastMid = midList.last.mid;

      emit(state.copyWithWalletState(interfaceMessageList: messages,mid:lastMid ));
    });

    on<UpdateFileCoinPendingStateEvent>((event,emit) async{
      var box = OpenedBox.mesInstance;
      Chain.setRpcNetwork(event.rpc, event.chainType);
      List param = [];
      state.storeMessageList.forEach((n) async {
        param.add({"from":n.from,"nonce":n.nonce});
      });
      var result = await Chain.chainProvider.getMessagePendingState(param);
      result.forEach((n) {
        if(n.message){
          state.storeMessageList.forEach((m) {
            if((n.message.from == m.from) && (n.message.nonce == m.nonce)){
              if((n.message.cid == m.cid ) && (n.message.exit_code == 0)){
                var mes = CacheMessage(
                    hash: m['cid'],
                    to: m['to'],
                    from: m['from'],
                    value: m['value'],
                    blockTime: n.message['block_time'],
                    exitCode: n.message['exit_code'],
                    owner: n.from,
                    pending: 0,
                    rpc: m.rpc,
                    height: n.message['block_epoch'],
                    fee: n.message['gas_fee'],
                    mid: n['mid'],
                    nonce: n.message['nonce']
                );
                box.put(n.message.cid,mes);
              }else if((n.message.cid == m.cid ) && (n.message.exit_code != 0)){
                var mes = CacheMessage(
                    hash: m['cid'],
                    to: m['to'],
                    from: m['from'],
                    value: m['value'],
                    blockTime: n.message['block_time'],
                    exitCode: n.message['exit_code'],
                    owner: n.from,
                    pending: 0,
                    rpc: m.rpc,
                    height: n.message['block_epoch'],
                    fee: n.message['gas_fee'],
                    mid: n['mid'],
                    nonce: n.message['nonce']
                );
                box.put(n.message.cid,mes);
              }else{
                var mes = CacheMessage(
                    hash: m['cid'],
                    to: m['to'],
                    from: m['from'],
                    value: m['value'],
                    blockTime: n.message['block_time'],
                    exitCode: n.message['exit_code'],
                    owner: n.from,
                    pending: -1,
                    rpc: m.rpc,
                    height: n.message['block_epoch'],
                    fee: n.message['gas_fee'],
                    mid: n['mid'],
                    nonce: n.message['nonce']
                );
                box.put(n.message.cid,mes);
              }
            }
          });
        }
      });

      List list = getStoreMsgList();
      emit(state.copyWithWalletState(storeMessageList: list ));
    });

    on<UpdateEthMessageListStateEvent>((event, emit) async{
      Chain.setRpcNetwork(event.rpc, event.chainType);
      var box = OpenedBox.mesInstance;
      var pendingList = box.values
          .where((mes) => mes.pending == 1 && mes.rpc == $store.net.rpc)
          .toList();

      if (pendingList.isNotEmpty) {
        try {
          var list = await Future.wait<TransactionReceipt>(
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
            Chain.setRpcNetwork($store.net.rpc, $store.net.addressType);
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
            // setList();
          }
        } catch (e) {
          print(e);
        }
      }
    });

    on<GetStoreMessageListEvent>((event,emit){
      List list = getStoreMsgList();
      emit(state.copyWithWalletState(storeMessageList: list ));
      add(UpdateFileCoinPendingStateEvent(event.rpc, event.chainType));
    });

  }
}

List getStoreMsgList(){
  var list = <CacheMessage>[];
  var address = $store.wal.addr;
  var box = OpenedBox.mesInstance;
  box.values.forEach((message) {
    if ((message.from == address || message.to == address) &&
        message.rpc == $store.net.rpc) {
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