/// code : 0
/// data : null
/// message : ""
/// detail : ""

class FilecoinResponse {
  FilecoinResponse({
      this.code, 
      this.data, 
      this.message, 
      this.detail,});

  FilecoinResponse.fromJson(dynamic json) {
    code = json['code'];
    data = json['data'];
    message = json['message'];
    detail = json['detail'];
  }
  int code;
  dynamic data;
  String message;
  String detail;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = code;
    map['data'] = data;
    map['message'] = message;
    map['detail'] = detail;
    return map;
  }

}