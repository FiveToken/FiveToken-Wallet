class ChainMessageDetail {
  String value;
  String fee;
  String from;
  String to;
  String hash;
  int height;
  ChainMessageDetail(
      {this.value = '0',
      this.fee = '0',
      this.from = '',
      this.to = '',
      this.hash = '',
      this.height = 0});
}
