part of 'price_bloc.dart';

class PriceEvent {
  const PriceEvent();
}

class ResetUsdPriceEvent  extends PriceEvent {
     ResetUsdPriceEvent();
}

class GetPriceEvent extends PriceEvent{
  final String chainType;
  GetPriceEvent(this.chainType);
}


