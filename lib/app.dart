import 'package:connectivity/connectivity.dart';
import 'package:fil/bloc/connect/connect_bloc.dart';
import 'package:fil/bloc/lock/lock_bloc.dart';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/common/navigation.dart';
import 'package:fil/i10n/localization.dart';
import 'package:fil/lang/index.dart';
import 'package:fil/pages/main/index.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import './routes/routes.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/device.dart';
import 'package:fil/common/global.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/actions/event.dart';

import 'bloc/price/price_bloc.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class App extends StatefulWidget {
  final String initialRoute;

  App(this.initialRoute);

  @override
  State createState() {
    return AppState();
  }
}

class AppState extends State<App> with WidgetsBindingObserver {
  StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initDevice();
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
          Get.offAll(MainPage(),
              transition: Transition.fadeIn, arguments: {'url': l});
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
    $store.setEncryptionType(EncryptType.argon2);
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
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    super.didChangeAppLifecycleState(appLifecycleState);
    if (appLifecycleState == AppLifecycleState.resumed) {
      Global.eventBus.fire(AppStateChangeEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      duration: Duration(seconds: 30),
      dismissOtherOnShow: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => MainBloc(),
          ),
          BlocProvider(
              create: (ctx) => ConnectBloc(),
          ),
          BlocProvider(
              create: (ctx) => PriceBloc(),
          ),
          BlocProvider(
            create: (ctx) => LockBloc(),
          )
        ],
        child: BlocBuilder<MainBloc, MainState>(builder: (ctx, state) {
          return GetMaterialApp(
              locale: Locale(Global.langCode),
              translations: Messages(),
              title: "FiveToken",
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
              });
        }),
      ),
    );
  }
}
