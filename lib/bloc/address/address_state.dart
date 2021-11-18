part of 'address_bloc.dart';

class AddressState extends Equatable{
   final List<ContactAddress> list;
   final Network net;
   const AddressState({this.list, this.net});

   factory AddressState.idle(){
     return const AddressState(list: []);
   }

   AddressState copy(List<ContactAddress> list, Network net) {
      return AddressState(
         list: list ?? this.list,
         net: net ?? this.net
      );
   }

   AddressState setList(List<ContactAddress> list){
      return AddressState(
          list: list ?? this.list,
      );
   }

   AddressState setNetwork(Network net){
      return AddressState(
          net: net ?? this.net
      );
   }

   @override
   List<Object> get props => [list, net];

}

