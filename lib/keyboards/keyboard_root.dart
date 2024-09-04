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
    // TODO: implement createState
    return KeyboardRootState();
  }
}

class KeyboardRootState extends State<KeyboardRootWidget> {
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
    // TODO: implement build
    return KeyboardMediaQuery(child: Builder(builder: (context) {
      CoolKeyboard.init(this, context);

      List<Widget> children = [widget.child];
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

  void setKeyboard(WidgetBuilder keyboardBuilder) {
    _keyboardBuilder = keyboardBuilder;
    setState(() {});
  }

  void clearKeyboard() {
    if (_keyboardBuilder != null) {
      _keyboardBuilder = null;
      setState(() {});
    }
  }
}
