import 'dart:async';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:logger/logger.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

//import 'package:web_socket_channel/status.dart' as status;

var _loggerPrinter = PrettyPrinter(
  methodCount: 0,
  errorMethodCount: 0,
  lineLength: 50,
  colors: false,
  printEmojis: false,
  printTime: false,
);

class WCMeta {
  String description, url, name;
  List<dynamic> icons;
  WCMeta.fromJson(Map<String, dynamic> map) {
    description = map['description'];
    url = map['url'];
    name = map['name'];
    icons = map['icons'];
  }
}

class WCCustomException implements Exception {
  JsonRpc request;
  JsonRpc result;
  dynamic error;
  dynamic cause;
  String errorType;
  WCCustomException(this.request, this.errorType,
      {this.error, this.result, this.cause});
}

class WCUri {
  WCUri(this.topic, this.version, this.bridgeUrl, this.keyHex);

  String topic;
  int version;
  String bridgeUrl;
  String keyHex;

  @override
  String toString({encode = true}) {
    var encodedBridgeUrl = encode ? Uri.encodeComponent(bridgeUrl) : bridgeUrl;
    return 'wc:$topic@$version?bridge=$encodedBridgeUrl&key=$keyHex';
  }

  static WCUri fromString(String wcUrl) {
    var rx = RegExp(r'wc:([^@]+)@(\d+)\?bridge=([^&]+)&key=([0-9a-fA-F]+)');
    var match = rx.firstMatch(wcUrl.trim());
    if (match != null) {
      return WCUri(match.group(1), int.parse(match.group(2)),
          Uri.decodeFull(match.group(3)), match.group(4));
    } else {
      throw ('malformed walletconnect uri');
    }
  }
}

class JsonRpc {
  JsonRpc(this.id, {this.method, this.params, this.result, this.error});

  int id;
  String jsonrpc = '2.0';
  String method;
  List<dynamic> params;
  Map<String, dynamic> result;
  Map<String, dynamic> error;
  Completer completer;
  factory JsonRpc.fromJson(Map<String, dynamic> jsonRpcObj) {
    return JsonRpc(jsonRpcObj['id'],
        method: jsonRpcObj['method'],
        result: jsonRpcObj['result'],
        error: jsonRpcObj['error'],
        params: jsonRpcObj['params']);
  }

  Map<String, dynamic> toJson() {
    if (method != null) {
      return {'id': id, 'jsonrpc': jsonrpc, 'method': method, 'params': params};
    } else if (result != null) {
      return {'id': id, 'jsonrpc': jsonrpc, 'result': result};
    } else {
      return {'id': id, 'jsonrpc': jsonrpc, 'error': error};
    }
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class WCPubSub {
  WCPubSub({this.topic, this.type, this.payload, this.silent});

  String topic;
  String type;
  String payload;
  bool silent;
  WCPubSub.fromJson(Map<String, dynamic> json)
      : topic = json['topic'],
        type = json['type'],
        payload = json['payload'],
        silent = json['silent'];

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() =>
      {'topic': topic, 'type': type, 'payload': payload, 'silent': silent};
}

class WCPayload {
  WCPayload({this.data, this.hmac, this.iv});

  String data;
  String hmac;
  String iv;

  WCPayload.fromJson(Map<String, dynamic> json)
      : data = json['data'],
        hmac = json['hmac'],
        iv = json['iv'];

  Map<String, dynamic> toJson() => {'data': data, 'hmac': hmac, 'iv': iv};
}

class WCConnectionRequest {
  WCConnectionRequest(
      {this.wcUri,
      this.webSocketChannel,
      this.streamSubscription,
      this.requestResponse,
      this.wcSessionRequest});

  WebSocketChannel webSocketChannel;
  StreamSubscription<dynamic> streamSubscription;
  Future<WCSession> wcSessionRequest;
  Future<dynamic> requestResponse;
  WCUri wcUri;
}

WCPubSub wcPubSub(topicId, payload, type, isSilent) {
  return WCPubSub(
      topic: topicId,
      payload: jsonEncode(payload),
      type: type,
      silent: isSilent);
}

class WCSession {
  WCSession(
      {this.sessionTopic,
      this.webSocketChannel,
      this.keyHex,
      this.ourPeerId,
      this.logger,
      this.eventHandler,
      this.chainId,
      this.bridgeUrl});

  WebSocketChannel webSocketChannel;
  StreamSubscription<dynamic> streamSubscription;
  Logger logger;
  String bridgeUrl;
  String sessionTopic;
  String keyHex;
  String ourPeerId;
  bool isConnected = false;
  bool isActive = false;
  Map<int, Tuple2<JsonRpc, Completer<dynamic>>> outstandingRpc = {};
  Map<String, List<JsonRpc Function(WCSession, JsonRpc)>> eventHandler = {};
  int theirChainId;
  List<dynamic> theirAccounts;
  int chainId;
  String theirRpcUrl;
  String theirPeerId;
  Map<String, dynamic> theirMeta;

  Future<dynamic> timeoutAfter({int sec, Function() onTimeout}) async {
    return Future.delayed(Duration(seconds: sec), onTimeout);
  }

  Future<Tuple2<int, Future<dynamic>>> sendRequest(method, params,
      {peerId, int timeoutSec}) async {
    if (!isConnected && method != 'wc_sessionRequest') {
      if (isActive) {
        logger.d('reconnect $this');
        await connect();
      } else {
        return Future.error('invalid session');
      }
    }
    var id = DateTime.now().millisecondsSinceEpoch;
    var jsonRpc = JsonRpc(id, method: method, params: params);
    var ivHex = IV.fromSecureRandom(16).base16;
    var wcRequest = wcEncrypt(jsonEncode(jsonRpc), keyHex, ivHex);
    var wcRequestPub = wcPubSub(peerId ?? theirPeerId, wcRequest, 'pub', true);
    var completer = Completer<dynamic>();
    var responseJsonRpc = JsonRpc(id, result: {'status': 'success'});
    if (method != 'wc_sessionUpdate') {
      outstandingRpc[id] = Tuple2(jsonRpc, completer);
    }
    webSocketChannel.sink.add(jsonEncode(wcRequestPub));
    return Tuple2(
        id,
        ((timeoutSec ?? 0) <= 0
            ? completer.future
            : Future.any([
                method == 'wc_sessionUpdate'
                    ? Future.value(Tuple2(jsonRpc, responseJsonRpc))
                    : completer.future,
                timeoutAfter(
                  sec: timeoutSec,
                  onTimeout: () {
                    try {
                      outstandingRpc.remove(id);
                      // ignore: empty_catches
                    } catch (e) {}
                    return Future.error(WCCustomException(jsonRpc, 'timeout',
                        error: {
                          'message': 'no response after ${timeoutSec}s'
                        }));
                  },
                )
              ])));
  }

  Future<Tuple2<int, Future<dynamic>>> sendResponse(id, method,
      {result, error, peerId}) async {
    if (!isConnected && method != 'wc_sessionRequest') {
      if (isActive) {
      } else {
        return Future.error('invalid session');
      }
    }
    var jsonRpc = JsonRpc(id, result: result, error: error);
    var ivHex = IV.fromSecureRandom(16).base16;
    var wcRequest = wcEncrypt(jsonEncode(jsonRpc), keyHex, ivHex);
    var wcRequestPub = wcPubSub(theirPeerId, wcRequest, 'pub', true);
    webSocketChannel.sink.add(jsonEncode(wcRequestPub));
    return Tuple2(id, Future.value(true));
  }

  Future<WCSession> sendSessionRequest(myMeta, {int timeoutSec}) async {
    var wcSessionRequestParams = [
      {'peerId': ourPeerId, 'peerMeta': myMeta, 'chainId': chainId}
    ];
    // ignore: unused_local_variable
    var request = await sendRequest('wc_sessionRequest', wcSessionRequestParams,
        peerId: sessionTopic, timeoutSec: timeoutSec);
    // ignore: unused_local_variable
    var id = request.item1;
    // ignore: unused_local_variable
    var result = await request.item2;
    return this;
  }

  Future<Tuple2<int, Future<dynamic>>> sendSessionRequestResponse(
      JsonRpc sessionRequest,
      String myName,
      Map<String, dynamic> myMeta,
      List<String> accounts,
      bool approved,
      {String rpcUrl,
      int chainId,
      bool ssl = true}) {
    var wcSessionRequestResult = {
      'approved': approved,
      'accounts': accounts,
      'rpcUrl': rpcUrl,
      'ssl': ssl,
      'networkId': chainId,
      'peerId': ourPeerId,
      'name': myName,
      'peerMeta': myMeta,
      'chainId': chainId
    };
    try {
      var response = sendResponse(sessionRequest.id, sessionRequest.method,
          result: wcSessionRequestResult);
      if (approved) {
        isConnected = true;
        isActive = true;
        var wcRequestSub = wcPubSub(ourPeerId, null, 'sub', true);
        webSocketChannel.sink.add(jsonEncode(wcRequestSub));
      }
      return response;
    } catch (err) {
      return Future.error(err);
    }
  }

  Future<dynamic> close() async {
    isConnected = false;
    return timeoutAfter(
        sec: 0,
        onTimeout: () async {
          return await webSocketChannel.sink.close(
              1000,
              isActive
                  ? 'socket released session still active'
                  : 'session destroyed from local');
        });
  }

  Future<dynamic> destroy() async {
    var params = [
      {
        'approved': false,
        'chainId': chainId,
        'accounts': [],
        'rpcUrl': null,
      }
    ];
    await sendRequest('wc_sessionUpdate', params);
    isActive = false;
    isConnected = false;
    return close();
  }

  void setEventHandler(method, handler, {remove = false}) {
    eventHandler ??= {};
    if (!eventHandler.containsKey(method)) {
      eventHandler[method] = [];
    }
    var handlers = eventHandler[method];
    if (!remove) {
      handlers.contains(handler) ?? handlers.add(handler);
    } else {
      handlers.contains(handler) ?? handlers.remove(handler);
    }
  }

  @override
  String toString() {
    var obj = {
      'ourPeerId': ourPeerId,
      'theirPeerId': theirPeerId,
      'theirMeta': theirMeta,
      'isConnected': isConnected,
      'isActive': isActive,
      'theirChainId': theirChainId,
      'theirRpcUrl': theirRpcUrl,
      'accounts': theirAccounts,
      'bridgeUrl': bridgeUrl,
      'keyHex': keyHex
    };
    return jsonEncode(obj);
  }



  Future<WCSession> connect(
      {String topic,
      void Function(WCSession, JsonRpc) sessionRequestHandler}) async {
    try {
      var wsUrl = bridgeUrl.replaceFirst(RegExp(r'^http'), 'ws');
      var subTopic = topic ?? ourPeerId;
      var wcSessionSub = wcPubSub(subTopic, null, 'sub', true);
      var channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      logger.d('session $this $wcSessionSub');
      final _stream = channel.stream;
      // StreamSubscription<dynamic> _s = _stream.listen((event) { });

      streamSubscription = _stream.listen((message) {
        try {
          final jsonRpc = wcDecodePubSubMessage(message, keyHex);
          var method = jsonRpc.method;

          if (method == 'wc_sessionRequest') {
            var params = jsonRpc.params;
            if (params != null && params.isNotEmpty) {
              var request = params[0];
              theirMeta = request['peerMeta'];
              theirPeerId = request['peerId'];
              theirChainId = request['chainId'];
              theirRpcUrl = request['rpcUrl'];
              theirAccounts = request['accounts'];
            }
            if (sessionRequestHandler != null) {
              sessionRequestHandler(this, jsonRpc);
            }
          } else if (method == 'wc_sessionUpdate') {
            var params = jsonRpc.params;
            if (params != null && params.isNotEmpty) {
              var request = params[0];
              isConnected = request['approved'];
              isActive = isConnected;
              theirChainId = request['chainId'];
              theirRpcUrl = request['rpcUrl'];
              theirAccounts = request['accounts'];
            }
          }

          if (method != 'wc_sessionRequest' ||
              (eventHandler != null &&
                  eventHandler.containsKey('wc_sessionRequest') &&
                  eventHandler['wc_sessionRequest'].isNotEmpty)) {
            processMessage(this, jsonRpc);
          }
        } catch (err) {
          logger.d('bad walletconnect request $err');
        }
      }, onError: (err, stack) {
        logger.d('$this socket error, $err $stack');
      }, onDone: () {
        isConnected = false;
        logger.d('$this socket done, session active: $isActive');
      }, cancelOnError: true);

      webSocketChannel = channel;
      channel.sink.add(jsonEncode(wcSessionSub));
      return Future.value(this);
    } catch (err, stack) {
      return Future.error(err, stack);
    }
  }

  static Future<WCConnectionRequest> createSession(
      String bridgeUrl, Map<String, dynamic> myMeta,
      {Map<String, List<JsonRpc Function(WCSession, JsonRpc)>> jsonRpcHandler,
      Logger logger,
      int chainId,
      int timeoutSec}) async {
    var uuidGenerator = Uuid();
    var sessionTopic = uuidGenerator.v4();
    var myPeerId = uuidGenerator.v4();
    var keyHex = Key.fromSecureRandom(32).base16;
    var wcVersion = 1;
    var wcSession = WCSession(
        keyHex: keyHex,
        sessionTopic: sessionTopic,
        ourPeerId: myPeerId,
        bridgeUrl: bridgeUrl,
        chainId: chainId,
        logger: logger ?? Logger(printer: _loggerPrinter),
        eventHandler: jsonRpcHandler);
    var wcUri = WCUri(sessionTopic, wcVersion, bridgeUrl, keyHex);

    try {
      await wcSession.connect();
      return WCConnectionRequest(
          wcUri: wcUri,
          webSocketChannel: wcSession.webSocketChannel,
          streamSubscription: wcSession.streamSubscription,
          wcSessionRequest:
              wcSession.sendSessionRequest(myMeta, timeoutSec: timeoutSec));
    } catch (err, stack) {
      wcSession.logger.d('create session error, $err, $stack');
      return Future.error(err, stack);
    }
  }

  static Future<Tuple2<WCSession, JsonRpc>> connectSession(String wcUrl,
      {Map<String, List<JsonRpc Function(WCSession, JsonRpc)>> jsonRpcHandler,
      Logger logger}) async {
    var uuidGenerator = Uuid();
    var wcUri = WCUri.fromString(wcUrl);
    var bridgeUrl = wcUri.bridgeUrl.trim();
    var keyHex = wcUri.keyHex;
    var sessionTopic = wcUri.topic;
    var myPeerId = uuidGenerator.v4();
    var sessionRequestCompleter = Completer<Tuple2<WCSession, JsonRpc>>();
    var wcSession = WCSession(
        keyHex: keyHex,
        sessionTopic: sessionTopic,
        ourPeerId: myPeerId,
        bridgeUrl: bridgeUrl,
        logger: logger ?? Logger(printer: _loggerPrinter),
        eventHandler: jsonRpcHandler);
    void handleSessionRequest(wcSession, jsonRpc) {
      sessionRequestCompleter.complete(Tuple2(wcSession, jsonRpc));
    }

    try {
      await wcSession.connect(
          topic: sessionTopic, sessionRequestHandler: handleSessionRequest);
      return sessionRequestCompleter.future;
    } catch (err, stack) {
      wcSession.logger.d('connect session error, $err, $stack');
      return Future.error(err, stack);
    }
  }
}

WCPayload wcEncrypt(data, keyHex, ivHex) {
  var iv = IV.fromBase16(ivHex);
  var key = Key.fromBase16(keyHex);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(data, iv: iv);
  var hmac = Hmac(sha256, hex.decode(keyHex)); // HMAC-SHA256
  var toBeSigned = encrypted.bytes + iv.bytes;
  var sig = hmac.convert(toBeSigned);
  return WCPayload(data: encrypted.base16, hmac: sig.toString(), iv: ivHex);
}

String wcDecrypt(dataHex, keyHex, ivHex, {dataSig}) {
  var iv = IV.fromBase16(ivHex);
  var key = Key.fromBase16(keyHex);
  var hmac = Hmac(sha256, hex.decode(keyHex));
  var sig = hmac.convert(hex.decode(dataHex) + iv.bytes).toString();
  if (dataSig != sig) {
    throw Exception('pubsub hmac mis-match $dataSig vs calcualted $sig');
  }
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final decrypted = encrypter.decrypt16(dataHex, iv: iv);
  return decrypted;
}

JsonRpc wcDecodePubSubMessage(message, keyHex) {
  var pubsub = jsonDecode(message);
  var payload = jsonDecode(pubsub['payload']);
  var wcRequest = wcDecrypt(payload['data'], keyHex, payload['iv'],
      dataSig: payload['hmac']);
  var jsonRpc = JsonRpc.fromJson(jsonDecode(wcRequest));
  return jsonRpc;
}

void processMessage(WCSession wcSession, JsonRpc jsonRpc) {
  var id = jsonRpc.id;
  var method = jsonRpc.method;
  //var params = jsonRpc.params;
  var result = jsonRpc.result;
  var error = jsonRpc.error;
  var internalErr;
  var handled = false;
  var hasHandler = false;
  var logger = wcSession.logger;
  if (method != null) {
    if (wcSession.eventHandler != null) {
      var handlers = wcSession.eventHandler.containsKey(method)
          ? wcSession.eventHandler[method]
          : [];
      for (var handler in handlers) {
        try {
          hasHandler = true;
          handler(wcSession, jsonRpc);
          handled = true;
        } catch (err) {
          internalErr = err;
          logger.d('$err');
        }
      }
    }
    if (!handled && !hasHandler && wcSession.eventHandler.containsKey('_')) {
      var handlers = wcSession.eventHandler['_'];
      for (var handler in handlers) {
        try {
          handler(wcSession, jsonRpc);
          handled = true;
        } catch (err) {
          internalErr = err;
          logger.d('$err');
        }
      }
    }
    if (!handled) {
      var errorResponse = {
        'id': jsonRpc.id,
        'error': {
          'code': internalErr != null ? -32063 : -32601,
          'message':
              internalErr != null ? internalErr.toString() : 'method not found'
        }
      };
      wcSession.sendResponse(jsonRpc.id, jsonRpc.method, error: errorResponse);
    }
  } else if (result != null || error != null) {
    if (wcSession.outstandingRpc.containsKey(id)) {
      var request = wcSession.outstandingRpc[id].item1;
      var completer = wcSession.outstandingRpc[id].item2;
      wcSession.outstandingRpc.remove(id);
      if (request.method == 'wc_sessionRequest') {
        if (result != null) {
          wcSession.theirMeta = result['peerMeta'];
          wcSession.theirPeerId = result['peerId'];
          wcSession.isConnected = result['approved'];
          wcSession.theirChainId = result['chainId'];
          wcSession.theirRpcUrl = result['rpcUrl'];
          wcSession.theirAccounts = result['accounts'];
          wcSession.isActive = wcSession.isConnected;
        }
      }
      if (completer != null) {
        if (result != null) {
          completer.complete(Tuple2(request, jsonRpc));
        } else {
          logger.d('error on request $request $jsonRpc');
          completer.completeError(
              WCCustomException(request, 'server', error: error));
        }
      }
    } else {
      logger.d('no matching request for response $jsonRpc');
    }
  } else {
    logger.d('uknown request $method');
  }
}
