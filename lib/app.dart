import 'package:connectivity/connectivity.dart';
import 'package:fil/common/navigation.dart';
import 'package:fil/i10n/localization.dart';
import 'package:fil/index.dart';
import 'package:fil/lang/index.dart';
import 'package:fil/pages/main/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import './routes/routes.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class App extends StatefulWidget {
  final String initialRoute;
  App(this.initialRoute);
  @override
  State createState() {
    return AppState();
  }
}

class AppState extends State<App> {
  StreamSubscription _sub;
  @override
  void initState() {
    super.initState();
    initDevice();
    initRequest();
    nextTick(() => initUniLinks());
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
  }

  Future<Null> initUniLinks() async {
    try {
      String initialLink = await getInitialLink();
      void checkAndGo(String link) {
        var l = getValidWCLink(link);
        if (l != '') {
          Get.offAll(MainPage(),transition: Transition.fadeIn,arguments: {'url': l});
        }
      }

      if (initialLink != null) {
        checkAndGo(initialLink);
      }
      _sub = getLinksStream().listen((String link) {
        checkAndGo(link);
      }, onError: (err) {
        print(err.toString());
      });
    } on PlatformException {
      print('parse error');
    }
  }

  void initDevice() async {
    await initDeviceInfo();
    await listenNetwork();
  }

  Future listenNetwork() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool online = connectivityResult != ConnectivityResult.none;
    Global.online = online;
    Connectivity().onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        Global.online = false;
      } else {
        Global.online = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
        duration: Duration(seconds: 30),
        dismissOtherOnShow: true,
        child: GetMaterialApp(
            locale: Locale(Global.langCode),
            translations: Messages(),
            title: "Filecoin Wallet",
            getPages: initRoutes(),
            debugShowCheckedModeBanner: false,
            initialRoute: widget.initialRoute,
            theme: ThemeData(
                appBarTheme: AppBarTheme(brightness: Brightness.light),
                primaryColor: CustomColor.primary),
            defaultTransition: Transition.cupertino,
            navigatorObservers: [routeObserver, PushObserver()],
            localizationsDelegates: [
              // ... app-specific localization delegate[s] here
              ChineseCupertinoLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('en', 'US'), // English
              const Locale('zh', 'ZH'), // Chinese
              // ... other locales the app supports
            ],
            builder: (BuildContext context, Widget child) {
              return GestureDetector(
                child: RefreshConfiguration(
                    child: child, headerTriggerDistance: 50),
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus &&
                      currentFocus.focusedChild != null) {
                    FocusManager.instance.primaryFocus.unfocus();
                  }
                },
              );
            }));
  }
}
