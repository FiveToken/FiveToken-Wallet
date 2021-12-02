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
      List storeMessageList = getStoreMsgList();
      List pendingList = storeMessageList.where((mes) => mes.pending == 1).toList();
      if(event.chainType == 'filecoin'){
        if(pendingList.length > 0){
          Chain.setRpcNetwork(event.rpc, event.chainType);
          List param = [];
          pendingList.forEach((n) async {
            param.add({"from":n.from,"nonce":n.nonce});
          });
          await upDateFileCoinMessageState(event.rpc,event.chainType,pendingList,param);
        }

        var result = await getInterfaceFileCoinMessageList(event.rpc,event.chainType,state.mid,event.actor,event.direction);
        var interfaceMessageList = result.list;
        var _mid = result.mid;
        var _enablePullUp = result.enablePullUp;
        List _storeList = getStoreMsgList();
        emit(state.copyWithWalletState(
          storeMessageList: _storeList,
          interfaceMessageList:interfaceMessageList,
          mid:_mid,
          enablePullUp:_enablePullUp,
        ));
      }else{
        if(pendingList.length > 0){
          await updateEthMessageListState(event.rpc,event.chainType,pendingList);
        }
        final _storeList = getStoreMsgList().map((e) => e).toList();
        emit(state.copyWithWalletState(
          storeMessageList: _storeList,
        ));
      }
    });

    on<SetEnablePullUpEvent>((event,emit){
      emit(state.copyWithWalletState(enablePullUp:event.enablePullUp));
    });

  }
}

Future getInterfaceFileCoinMessageList(rpc,chainType,mid,actor,direction) async {
  String _mid = mid ?? '';
  Chain.setRpcNetwork(rpc, chainType);
  var result = await Chain.chainProvider.getFileCoinMessageList(
      actor: actor,
      direction: direction,
      mid: _mid
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
  return {
    "list":messages,
    "mid":lastMid,
    "enablePullUp":result.length >= 10
  };
}

Future<void> upDateFileCoinMessageState(rpc,chainType,param,pendingList) async {
  var box = OpenedBox.mesInstance;
  Chain.setRpcNetwork(rpc, chainType);
  var result = await Chain.chainProvider.getMessagePendingState(param);
  result.forEach((n) {
    var message = n['message'];
    if(message.isNotEmpty){
      pendingList.forEach((m) {
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
}

Future<void> updateEthMessageListState(rpc,chainType,pendingList) async {
  try{
    Chain.setRpcNetwork(rpc, chainType);
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
  }catch(error){
    debugPrint("error");
  }
}

List<CacheMessage> getStoreMsgList(){
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

  return list ?? [];
}