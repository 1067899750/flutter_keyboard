part of cool_ui;

///
/// 用于注册键监听系统键盘
/// 放在 main 中  main()  方法中
///
class KeyboardRootWidget extends StatefulWidget {
  final Widget child;

  /// The text direction for this subtree.
  final TextDirection textDirection;

  const KeyboardRootWidget(
      {Key? key, required this.child, this.textDirection = TextDirection.ltr})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return KeyboardRootState();
  }
}

///
/// 承装键盘试图的 widget
///
class KeyboardRootState extends State<KeyboardRootWidget> {

  KeyboardRootState({Key? key});

  // 键盘构建试图
  WidgetBuilder? _keyboardBuilder;

  bool get hasKeyboard => _keyboardBuilder != null;

  // List<OverlayEntry> _initialEntries = [];

  @override
  void initState() {
    super.initState();
    // _initialEntries.add(this.initChild());
  }

  @override
  Widget build(BuildContext context) {
    // 用于这里控制 flutter 界面里面所有有关的键盘事件
    return KeyboardMediaQuery(child: Builder(builder: (context) {
      // 初始化监听键盘事件
      CoolKeyboard.init(this, context);

      // flutter UI 试图
      List<Widget> children = [widget.child];

      // 键盘 widget
      if (_keyboardBuilder != null) {
        children.add(Builder(
          builder: _keyboardBuilder!,
        ));
      }
      return Directionality(
          textDirection: widget.textDirection,
          child: Stack(
            children: children,
          ));
    }));
  }

  ///
  /// 显示键盘
  ///
  void setKeyboard(WidgetBuilder keyboardBuilder) {
    _keyboardBuilder = keyboardBuilder;
    setState(() {});
  }

  ///
  /// 隐藏键盘
  ///
  void clearKeyboard() {
    if (_keyboardBuilder != null) {
      _keyboardBuilder = null;
      setState(() {});
    }
  }
}
