part of 'create_bloc.dart';

class CreateState extends Equatable {
   final String mne;
   final List<String> unSelectedList;
   final List<String> selectedList;
   final int type;
   const CreateState({this.mne, this.unSelectedList, this.selectedList, this.type});

   factory CreateState.idle(){
     return const CreateState(
         mne: '',
         unSelectedList: [],
         selectedList: [],
         type: 0
     );
   }

   CreateState copy(String mne, List<String> unSelectedList, List<String> selectedList ) {
     return CreateState(
       mne: mne ?? this.mne,
       unSelectedList: unSelectedList ?? this.unSelectedList,
       selectedList: selectedList ?? this.selectedList,
       type: type ?? this.type
     );
   }

   CreateState copyType(int num, List<String> unSelectedList, List<String> selectedList){
     return CreateState(
         type: num ?? this.type,
         unSelectedList: unSelectedList?? this.unSelectedList,
         selectedList: selectedList??this.selectedList
     );
   }


   @override
   List<Object> get props => [this.mne, this.unSelectedList, this.selectedList, this.type];

}

