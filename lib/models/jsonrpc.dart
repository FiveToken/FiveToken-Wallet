class JsonRPCRequest {
  num id;
  String method;
  List<dynamic> params;

  JsonRPCRequest(this.id, this.method, this.params);

  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      'id': this.id,
      'method': this.method,
      'params': this.params,
    };
  }
}

class JsonRPCResponse {
  String jsonrpc;
  num id;
  dynamic error;
  dynamic result;

  JsonRPCResponse(this.jsonrpc, this.id, this.error, this.result);

  JsonRPCResponse.fromJson(Map<String, dynamic> json)
      : jsonrpc = json['jsonrpc'],
        id = json['id'],
        error = json['error'],
        result = json['result'];

}

class JsonRPCError {
  num code;
  String message;

  JsonRPCError(this.code, this.message);

  JsonRPCError.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        message = json['message'];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': this.code,
      'message': this.message,
    };
  }
}

class Address {
  String address;

  Address(this.address);
  Address.fromJson(Map<String, dynamic> json)
      : address = json['address'];

  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      'address': this.address
    };
  }
}