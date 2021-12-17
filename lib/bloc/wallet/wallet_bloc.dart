import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/time.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/request/global.dart';
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
      try{
        List storeMessageList = getStoreMsgList(event.symbol).map((e) => e).toList();
        final pendingList = storeMessageList.where((mes) => mes.pending == 1).toList();
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
          var _mid = result["mid"];
          var _enablePullUp = result["enablePullUp"];
          deleteSpeedUpMessages(event.symbol);
          List _storeList = getStoreMsgList(event.symbol).map((e) => e).toList();
          emit(state.copyWithWalletState(
              storeMessageList: _storeList,
              mid:_mid,
              enablePullUp:_enablePullUp,
              timestamp:DateTime.now().microsecondsSinceEpoch
          ));
        }else{
          if(pendingList.length > 0){
              await updateEthMessageListState(event.rpc,event.chainType,pendingList);
              deleteSpeedUpMessages(event.symbol);
          }
          final _storeList = getStoreMsgList(event.symbol).map((e) => e).toList();
          emit(state.copyWithWalletState(
            storeMessageList: _storeList,
            timestamp:DateTime.now().microsecondsSinceEpoch
          ));
        }
      }catch(error){}
    });

    on<GetFileCoinMessageListEvent>((event,emit) async {
      try{
        var result = await getInterfaceFileCoinMessageList(event.rpc,event.chainType,state.mid,event.actor,event.direction);
        var _mid = result['mid'];
        var _enablePullUp = result["enablePullUp"];
        final _storeList = getStoreMsgList(event.symbol).map((e) => e).toList();
        emit(state.copyWithWalletState(
            storeMessageList:_storeList,
            mid:_mid,
            enablePullUp:_enablePullUp,
            timestamp:DateTime.now().microsecondsSinceEpoch
        ));
      }catch(error){
        throw(error);
      }
    });

    on<GetTokenBalanceEvent>((event,emit) async {
      try{
        Chain.setRpcNetwork(event.rpc, event.chainType);
        final _balance = await Chain.chainProvider.getBalanceOfToken(event.mainAddress, event.address);
        String _key = event.address + event.rpc;
        final token = OpenedBox.tokenInstance.get(_key);
        var item = {
          "symbol": token.symbol,
          "precision": token.precision,
          "address": token.address,
          "rpc": token.rpc,
          "chain": token.chain,
          "balance": _balance
        };
        OpenedBox.tokenInstance.put(
            event.address + event.rpc,
            Token.fromJson(item)
        );
        Global.cacheToken = Token.fromJson(item);
        emit(state.copyWithWalletState(
            tokenBalance:_balance,
            timestamp:DateTime.now().microsecondsSinceEpoch
        ));
      }catch(error){
        throw(error);
      }

    });

    on<SetEnablePullUpEvent>((event,emit){
      emit(state.copyWithWalletState(enablePullUp:event.enablePullUp));
    });

    on<ResetMessageListEvent>((event,emit){
      emit(state.copyWithWalletState(
          storeMessageList: [],
          mid:'',
          enablePullUp:true,
          timestamp:DateTime.now().microsecondsSinceEpoch
      ));
    });

  }
}

getInterfaceFileCoinMessageList(rpc,chainType,mid,actor,direction) async {
  try{
    String _mid = mid ?? '';
    Chain.setRpcNetwork(rpc, chainType);
    var result = await Chain.chainProvider.getFileCoinMessageList(
        actor: actor,
        direction: direction,
        mid: _mid
    );
    if(result.length > 0){
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
          symbol: "FIL",
          nonce: map['nonce'],
        );
        messages.add(mes);
        box.put(map["cid"],mes);
      });
      messages = messages.toList();
      List midList = messages.where((mes) => mes.mid != '').toList();
      String lastMid = midList.last.mid;
      return {
        "mid":lastMid,
        "enablePullUp":result.length >= 10
      };
    }else{
      return {
        "mid":'',
        "enablePullUp":false
      };
    }
  }catch(error){
    return {
      "mid":'',
      "enablePullUp":false
    };
  }

}

upDateFileCoinMessageState(rpc,chainType,param,pendingList) async {
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

updateEthMessageListState(rpc,chainType,List<dynamic> pendingList) async {
  try{
    Chain.setRpcNetwork(rpc, chainType);
    var box = OpenedBox.mesInstance;

    var list = await Future.wait(
        pendingList.map((mes) => Chain.chainProvider.getTransactionReceipt(mes.hash)).toList());
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
    throw(error);
  }
}

List getStoreMsgList(symbol){
  try{
    var list = <CacheMessage>[];
    var address = $store.wal.addr;
    var box = OpenedBox.mesInstance;
    box.values.forEach((message) {
      if (
      (message.from == address || message.to == address)
          &&  message.rpc == $store.net.rpc && message.symbol == symbol

      ) {
        list.add(message);
      }
    });
    return list ?? [];
  }catch(error){
    return [];
  }
}

deleteSpeedUpMessages(symbol){
  var box = OpenedBox.mesInstance;
  var _storeList = getStoreMsgList(symbol);
  List<CacheMessage> pendingList = [];
  List<CacheMessage> resolvedList = [];

  _storeList.forEach((mes) {
    if (mes.pending == 1) {
      pendingList.add(mes);
    } else {
      resolvedList.add(mes);
    }
  });

  if (resolvedList.isNotEmpty && pendingList.isNotEmpty) {
    List<num> shouldDeleteNonce = [];
    var pendingNonce = pendingList.map((mes) => mes.nonce);
    resolvedList.forEach((mes) {
      if (pendingNonce.contains(mes.nonce)) {
        shouldDeleteNonce.add(mes.nonce);
      }
    });
    if (shouldDeleteNonce.isNotEmpty) {
      var deleteKeys = pendingList
          .where((mes) => shouldDeleteNonce.contains(mes.nonce))
          .map((mes) => mes.hash);
      box.deleteAll(deleteKeys);
    }
  }

}