// import 'package:fil/index.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/common/global.dart';
import 'package:fil/actions/event.dart';

typedef FreshCallback = Future Function();

class CustomRefreshWidget extends StatefulWidget {
  final Widget child;
  final bool enablePullDown;
  final bool enablePullUp;
  final bool listenAppState;
  final FreshCallback onRefresh;
  final FreshCallback onLoading;
  CustomRefreshWidget(
      {@required this.child,
      this.enablePullUp = true,
      this.enablePullDown = true,
      this.listenAppState = true,
      this.onLoading,
      @required this.onRefresh});
  @override
  State<StatefulWidget> createState() {
    return CustomRefreshWidgetState();
  }
}

class CustomRefreshWidgetState extends State<CustomRefreshWidget> {
  final RefreshController controller = RefreshController();
  void _onRefresh() async {
    Timer timer = Timer(Duration(seconds: 10), () {
      controller.refreshFailed();
    });
    try {
      await widget.onRefresh();
      timer.cancel();
      controller.refreshCompleted();
    } catch (e) {
      controller.refreshFailed();
    }
  }

  @override
  void initState() {
    super.initState();
    nextTick(() {
      controller.requestRefresh();
    });
    if (widget.listenAppState) {
      Global.eventBus.on<AppStateChangeEvent>().listen((event) {
        controller.requestRefresh();
      });
    }
    Global.eventBus.on<ShouldRefreshEvent>().listen((event) {
      controller.requestRefresh();
    });
  }

  void _onLoading() async {
    Timer timer = Timer(Duration(seconds: 10), () {
      controller.loadFailed();
    });
    try {
      await widget.onLoading();
      timer.cancel();
      controller.loadComplete();
    } catch (e) {
      controller.loadFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: controller,
      enablePullDown: widget.enablePullDown,
      enablePullUp: widget.enablePullUp,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      header: WaterDropHeader(
        waterDropColor: CustomColor.primary,
        complete: Text('finish'.tr),
        failed: Text('loadFail'.tr),
      ),
      footer: CustomFooter(builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = Text('loadMore'.tr);
        } else if (mode == LoadStatus.loading) {
          body = CupertinoActivityIndicator();
        } else if (mode == LoadStatus.failed) {
          body = Text('loadFail'.tr);
        } else if (mode == LoadStatus.canLoading) {
          body = Text('loadMore'.tr);
        } else {
          body = Text("noMore".tr);
        }
        return Center(
          child: body,
        );
      }),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
