import 'package:fil/index.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef FreshCallback = Future Function();

class CustomRefreshWidget extends StatefulWidget {
  final Widget child;
  final bool enablePullDown;
  final bool enablePullUp;
  final FreshCallback onRefresh;
  final FreshCallback onLoading;
  CustomRefreshWidget(
      {@required this.child,
      this.enablePullUp = true,
      this.enablePullDown = true,
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
    nextTick((){
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
        failed: Text('加载失败'),
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
