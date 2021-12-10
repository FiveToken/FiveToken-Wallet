import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/lock/lock_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/chain/net.dart';
void main() {
  group('lockBloc',(){
    LockBloc lockBloc;

    setUp((){
      lockBloc = LockBloc();
    });

    blocTest(
        'emit when',
        build: ()=> lockBloc,
        act: (bloc) => bloc.add(SetLockEvent(lock:true, password: '123456', status: 'update')),
        expect: ()=> [LockState(lock:true, password: '123456', status: 'update')]
    );
  });
}