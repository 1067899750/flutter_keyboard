part of cool_ui;

///
///
/// 按键
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

  const BoardBtnWidget({
    super.key,
    required this.width,
    required this.height,
    required this.title,
    this.value,
    required this.controller,
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
        color: Color(color),
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
        onTapDown: (TapDownDetails details){
          widget.controller.addText(widget.value ?? widget.title);
          setState(() {
            _isSelect = true;
          });
        },
        onTapUp: (TapUpDetails details){
          setState(() {
            _isSelect = false;
          });
        },
      ),
    );
  }
}
