part of cool_ui;

///
///
/// 键盘外部框
///
///
class BoardCardWidget extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  final KeyboardController controller;

  const BoardCardWidget(
      {super.key,
      required this.child,
      required this.width,
      required this.height,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(color: Color(0xFF7d7d7d)),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: width,
                height: 35.0,
                alignment: Alignment.center,
                child: const Text(
                  '招商银行安全输入',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFFbfbfbf),
                  ),
                ),
              ),
              Positioned(
                right: 0.0,
                child: GestureDetector(
                  onTap: () {
                    controller.doneAction();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Text(
                      '完成',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFFffffff),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
            color: const Color(0xFF555457),
            width: width,
            height: 1.0,
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
