part of 'pass_bloc.dart';

class PassState extends Equatable {
  final bool passShow;

  const PassState({this.passShow});

  @override
  // TODO: implement props
  List<Object> get props => [passShow];

  factory PassState.idle() {
    return PassState(passShow: false);
  }

  PassState copy({bool passShow}){
    return PassState(
        passShow: passShow ??  this.passShow
    );
  }

}

