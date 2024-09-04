part of cool_ui;

///
/// 用于注册键监听系统键盘
/// 放在需要用自定义键盘 widget 中
///
class KeyboardMediaQuery extends StatefulWidget {
  final Widget child;

  const KeyboardMediaQuery({super.key, required this.child});

  @override
  State<StatefulWidget> createState() => KeyboardMediaQueryState();
}

class KeyboardMediaQueryState extends State<KeyboardMediaQuery> {
  double keyboardHeight = 0;
  ValueNotifier<double> keyboardHeightNotifier =
      CoolKeyboard._keyboardHeightNotifier;

  @override
  void initState() {
    super.initState();
    CoolKeyboard._keyboardHeightNotifier.addListener(onUpdateHeight);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var data = MediaQuery.maybeOf(context);
    data ??= MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    var bottom = CoolKeyboard._keyboardHeightNotifier.value != 0
        ? CoolKeyboard._keyboardHeightNotifier.value
        : data.viewInsets.bottom;
    // TODO: implement build
    return MediaQuery(
        data: data.copyWith(
            viewInsets: data.viewInsets.copyWith(bottom: bottom)),
        child: widget.child);
  }

  void onUpdateHeight() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() => {});
      SchedulerBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.handleMetricsChanged();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    CoolKeyboard._keyboardHeightNotifier.removeListener(onUpdateHeight);
  }
}
