import 'package:fil/index.dart';
import 'package:oktoast/oktoast.dart';

var filscanWeb = Global.netPrefix == 'f'
    ? "https://filscan.io"
    : "https://calibration.filscan.io/#";
const API_MAIN = 'https://api.filscan.io:8700/';
const API_TEST = 'https://calibration.filscan.io:8800/';
var baseRequest = Dio();
void initRequest() {
  baseRequest.options.baseUrl = ServerAddress.use;
  baseRequest.options.connectTimeout = 20000;
}

class ServerAddress {
  static String get main => API_MAIN;
  static String get test => API_TEST;
  static String get use => Global.netPrefix == 'f' ? API_MAIN : API_TEST;
}

Future<Response> fetch(String method, List<dynamic> params,
    {bool loading = false}) async {
  if (loading) {
    showCustomLoading('Loading');
  }
  try {
    var data = JsonRPCRequest(1, method, params);
    var res = await baseRequest.post("/rpc/v1",
        data: data,
        options: Options(
          receiveTimeout: 20000,
          sendTimeout: 20000,
        ));
    if (loading) {
      dismissAllToast();
    }
    return res;
  } catch (e) {
    dismissAllToast();
    return Response();
  }
}
