import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/key.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/toast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';

part 'reset_event.dart';
part 'reset_state.dart';

class ResetBloc extends Bloc<ResetEvent, ResetState> {
  ResetBloc() : super(ResetState.idle()) {
    on<SetResetEvent>((event, emit) async {
      var wallet = event.wallet;
      var newPass = event.newPassword;
      var pass = event.password;
      var private = await wallet.getPrivateKey(pass);
      if(private==null){
        showCustomError('wrongOldPass'.tr);
        return;
      }
      var box = OpenedBox.walletInstance;
      var net = Network.getNetByRpc(wallet.rpc);
      var isId = wallet.type == 0;
      if (isId) {
        var list = box.values
            .where((wal) => wal.groupHash == wallet.groupHash)
            .toList();
        Map<String, EncryptKey> keyMap = {};
        for (var i = 0; i < list.length; i++) {
          var wal = list[i];
          var same = wal.addressType == wallet.addressType;
          var p = private;
          if(!same){
            try {
              p = await wal.getPrivateKey(pass);
            }catch(e){
              throw(e);
            }
          }
          var prefix = wal.rpc == Network.filecoinMainNet.rpc? 'f': 't';
          // var addr = wal.addressType;
          EncryptKey key;
          if(wal.addressType == 'eth'){
            var str = '$p\_$newPass';
            if(!keyMap.containsKey(str)){
              key = await EthWallet.genEncryptKeyByPrivateKey(p, newPass);
              keyMap[str] = key;
            }else{
              key = keyMap[str];
            }
          }else{
            var str = '$p\_$newPass\_$prefix';
            if(!keyMap.containsKey(str)){
              key = await FilecoinWallet.genEncryptKeyByPrivateKey(p, newPass,
                  prefix: prefix);
              keyMap[str] = key;
            }else{
              key = keyMap[str];
            }
          }
          wal.skKek = key.kek;
          box.put(wal.key, wal);
          if (net.rpc == $store.net.rpc) {
            $store.setWallet(wal);
          }
        }
      }
    });
  }
}
