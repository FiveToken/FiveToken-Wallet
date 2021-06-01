class MethodItem {
  final String label;
  final String value;
  MethodItem({this.label, this.value});
  MethodItem.fromJson(Map<String, dynamic> map)
      : label = map['label'],
        value = map['value'];
  static List<MethodItem> get methodList {
    return <MethodItem>[
      MethodItem.fromJson({'label': 'Transfer', 'value': '0'}),
      MethodItem.fromJson({'label': 'Withdraw', 'value': '16'}),
      MethodItem.fromJson({'label': 'ChangeOwnerAddress', 'value': '23'})
    ];
  }
}
