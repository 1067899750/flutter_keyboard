part of cool_ui;

///
/// 手机号输入键盘
///
class PhoneKeyboard extends StatelessWidget {
  final KeyboardController controller;

  const PhoneKeyboard({super.key, required this.controller});

  ///
  /// {0 ~ 9} 类型按键
  ///
  Widget buildButton(String title, double width, double height,
      {String? value}) {
    return BoardBtnWidget(
      width: width,
      height: height,
      title: title,
      value: value,
      controller: controller,
      btnType: BtnType.numAndWordType,
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double widgetWidth = mediaQuery.size.width;
    // 子组件的宽度
    double childWidth = (widgetWidth - 40) / 3;
    return Material(
      child: DefaultTextStyle(
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 23.0,
        ),
        child: BoardCardWidget(
          height: ScreenUtil.getBoardHeight(context),
          width: widgetWidth,
          controller: controller,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            double height = constraints.constrainHeight();
            double childHeight = (height - 30) / 4;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton('1', childWidth, childHeight),
                    buildButton('2', childWidth, childHeight),
                    buildButton('3', childWidth, childHeight),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildButton('4', childWidth, childHeight),
                      buildButton('5', childWidth, childHeight),
                      buildButton('6', childWidth, childHeight),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildButton('7', childWidth, childHeight),
                      buildButton('8', childWidth, childHeight),
                      buildButton('9', childWidth, childHeight),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 清除按键
                      BoardBtnWidget(
                        width: childWidth,
                        height: childHeight,
                        title: '清除',
                        controller: controller,
                        btnType: BtnType.clearType,
                      ),
                      buildButton('0', childWidth, childHeight),
                      // 删除按键
                      Container(
                        width: childWidth,
                        height: childHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1c69ac),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          child: const Center(
                            child: Image(
                              image: AssetImage(
                                  'assets/images/icon_shuzi_keyboard_del_default.png'),
                              width: 30,
                              height: 20,
                              fit: BoxFit.fill,
                            ),
                          ),
                          onTap: () {
                            controller.deleteOne();
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}
