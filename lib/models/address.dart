import 'package:fil/index.dart';
part 'address.g.dart';
@HiveType(typeId: 10)
class ContactAddress {
  @HiveField(0)
  String label;
  @HiveField(1)
  String address;
  @HiveField(2)
  String rpc;
  ContactAddress({this.label = '', this.address = '', this.rpc = ''});
}
