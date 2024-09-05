part of cool_ui;

///
///
/// 按键 widget
///
///
class BoardBtnWidget extends StatefulWidget {
  final double width;
  final double height;

  /// 按钮的名称
  final String title;

  /// 按钮选择是默认文案
  final String? value;
  final KeyboardController controller;

  /// 按键类型
  final BtnType btnType;

  ///按键字体背景颜色
  final Color? keyBgColor;

  ///按键回调
  final Function? callBack;

  const BoardBtnWidget({
    super.key,
    required this.width,
    required this.height,
    required this.title,
    this.value,
    required this.controller,
    this.btnType = BtnType.UNDEFINE,
    this.callBack,
    this.keyBgColor,
  });

  @override
  State<BoardBtnWidget> createState() => _BoardBtnWidgetState();
}

class _BoardBtnWidgetState extends State<BoardBtnWidget> {
  /// 按钮是否选择
  bool _isSelect = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int color = _isSelect ? 0xFF1c69ac : 0xFF474749;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.keyBgColor ?? Color(color),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Center(
          child: Text(
            widget.title,
            style: const TextStyle(
              color: Color(0xffffffff),
              fontSize: 18,
            ),
          ),
        ),
        onTapDown: (TapDownDetails details) {
          this.widget.callBack?.call();
          switch (widget.btnType) {
            case BtnType.UNDEFINE:
              break;
            case BtnType.numAndWordType:
              widget.controller.addText(widget.value ?? widget.title);
              break;
            case BtnType.clearType:
              widget.controller.clear();
              break;
          }

          setState(() {
            _isSelect = true;
          });
        },
        onTapUp: (TapUpDetails details) {
          setState(() {
            _isSelect = false;
          });
        },
      ),
    );
  }
}

///
///
/// 按键类型
///
///
enum BtnType {
  // 为定义类型
  UNDEFINE,
  // 清除按键
  clearType,
  // 数字和字母按键
  numAndWordType
}
