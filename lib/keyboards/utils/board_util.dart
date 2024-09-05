part of cool_ui;

///
///
/// 弹出键盘类型类
///
///
class BoardTypeUtil {
  ///
  /// 生份证键盘
  ///
  static CKTextInputType cardNumberType =
      const CKTextInputType(name: 'CardNumberKeyboard');

  ///
  /// 手机号键盘
  ///
  static CKTextInputType phoneType =
      const CKTextInputType(name: 'PhoneKeyboard');

  ///
  /// 数字键盘
  ///
  static CKTextInputType numberType =
      const CKTextInputType(name: 'NumberKeyboard');

  ///
  ///获取所有键盘类型
  ///
  static Map<BoardType, CKTextInputType> getAllBoardType() {
    return {
      BoardType.cardNumberType: cardNumberType,
      BoardType.phoneType: phoneType,
      BoardType.numberType: numberType,
    };
  }
}

///
///
///  键盘控制类
///
///
class BoardUtil {
  ///
  /// 注册键盘
  ///
  static register() {
    BoardTypeUtil.getAllBoardType().forEach((key, value) {
      CoolKeyboard.addKeyboard(
        value,
        KeyboardConfig(
            builder: (context, controller, params) {
              switch (key) {
                case BoardType.cardNumberType:
                  return CardNumberKeyboard(controller: controller);
                case BoardType.phoneType:
                  return PhoneKeyboard(controller: controller);
                case BoardType.numberType:
                  return NumberKeyboard(controller: controller);
                case BoardType.otherType:
                  return CardNumberKeyboard(controller: controller);
              }
            },
            getHeight: ScreenUtil.getBoardHeight),
      );
    });
  }
}

///
///
/// 键盘类型
///
///
enum BoardType {
  // 身份证键盘
  cardNumberType,
  // 电话
  phoneType,
  // 数字键盘
  numberType,
  // 其他
  otherType
}
