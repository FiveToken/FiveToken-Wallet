class Net {
  String key, name, api;

  Net({key: String, name: String, api: String}) {
    this.key = key;
    this.name = name;
    this.api = api;
  }
  Net.fromJson(Map<String, dynamic> json) {
    this.key = json['key'] as String;
    this.name = json['name'] as String;
    this.api = json['api'] as String;
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': this.key,
      'name': this.name,
      'api': this.api,
    };
  }
}