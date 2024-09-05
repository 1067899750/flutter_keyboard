part of cool_ui;

typedef GetKeyboardHeight = double Function(BuildContext context);
typedef KeyboardBuilder = Widget Function(
    BuildContext context, KeyboardController controller, String? param);

///
///
/// 用于监听键盘事件
///
///
class CoolKeyboard {
  static JSONMethodCodec codec = const JSONMethodCodec();
  static KeyboardConfig? _currentKeyboard;

  // 用于保存自定义键盘的配置
  static final Map<CKTextInputType, KeyboardConfig> _keyboards = {};
  // flutter 根试图
  static KeyboardRootState? _root;
  static BuildContext? _context;
  static KeyboardController? _keyboardController;
  static GlobalKey<KeyboardPageState>? _pageKey;
  static bool isInterceptor = false;

  static final ValueNotifier<double> _keyboardHeightNotifier = ValueNotifier(0)
    ..addListener(updateKeyboardHeight);

  static String? _keyboardParam;

  static Timer? clearTask;

  static init(KeyboardRootState root, BuildContext context) {
    _root = root;
    _context = context;
    interceptorInput();
  }

  ///
  /// 注册监听事件
  ///
  static void interceptorInput() {
    if (isInterceptor) return;
    if (ServicesBinding.instance is! MockBinding) {
      throw Exception('CoolKeyboard can only be used in MockBinding');
    }
    var mockBinding = ServicesBinding.instance as MockBinding;
    var mockBinaryMessenger = mockBinding.defaultBinaryMessenger;
    if (mockBinaryMessenger is MockBinaryMessenger) {
      mockBinaryMessenger.setMockMessageHandler(
          "flutter/textinput", _textInputHandler);
    }
    isInterceptor = true;
  }

  static Future<ByteData?> _textInputHandler(ByteData? data) async {
    var methodCall = codec.decodeMethodCall(data);
    switch (methodCall.method) {
      case 'TextInput.show': //打开键盘
        if (_currentKeyboard != null) {
          // 自定义键盘
          if (clearTask != null) {
            clearTask!.cancel();
            clearTask = null;
          }
          // 打开键盘
          openKeyboard();
          return codec.encodeSuccessEnvelope(null);
        } else {
          // 系统键盘
          if (data != null) {
            return await _sendPlatformMessage("flutter/textinput", data);
          }
        }
        break;
      case 'TextInput.hide': // 隐藏键盘
        if (_currentKeyboard != null) {
          clearTask ??= Timer(const Duration(milliseconds: 16),
              () => hideKeyboard(animation: true));
          return codec.encodeSuccessEnvelope(null);
        } else {
          if (data != null) {
            return await _sendPlatformMessage("flutter/textinput", data);
          }
        }
        break;
      case 'TextInput.setEditingState': //编辑状态
        var editingState = TextEditingValue.fromJSON(methodCall.arguments);
        if (_keyboardController != null) {
          _keyboardController!.value = editingState;
          return codec.encodeSuccessEnvelope(null);
        }
        break;
      case 'TextInput.clearClient': // 清除键盘
        var isShow = _currentKeyboard != null;
        clearTask ??= Timer(const Duration(milliseconds: 16),
            () => hideKeyboard(animation: true));
        clearKeyboard();
        if (isShow) {
          return codec.encodeSuccessEnvelope(null);
        }
        break;
      case 'TextInput.setClient':
        var setInputType = methodCall.arguments[1]['inputType'];
        InputClient? client;
        _keyboards.forEach((inputType, keyboardConfig) {
          if (inputType.name == setInputType['name']) {
            client = InputClient.fromJSON(methodCall.arguments);

            _keyboardParam =
                (client!.configuration.inputType as CKTextInputType).params;

            clearKeyboard();
            _currentKeyboard = keyboardConfig;
            _keyboardController = KeyboardController(client: client!)
              ..addListener(_updateEditingState);
            if (_pageKey != null) {
              _pageKey!.currentState?.update();
            }
          }
        });

        if (client != null) {
          await _sendPlatformMessage("flutter/textinput",
              codec.encodeMethodCall(const MethodCall('TextInput.hide')));
          return codec.encodeSuccessEnvelope(null);
        } else {
          if (clearTask == null) {
            hideKeyboard(animation: false);
          }
          clearKeyboard();
        }
      // break;
    }

    // 如果前面都没有拦截走系统事件
    if (data != null) {
      ByteData? response =
          await _sendPlatformMessage("flutter/textinput", data);
      return response;
    }
    return null;
  }

  ///
  /// 更新编辑状态
  ///
  static void _updateEditingState() {
    var callbackMethodCall = MethodCall("TextInputClient.updateEditingState", [
      _keyboardController!.client.connectionId,
      _keyboardController!.value.toJSON()
    ]);
    WidgetsBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        "flutter/textinput",
        codec.encodeMethodCall(callbackMethodCall),
        (data) {});
  }

  static Future<ByteData?> _sendPlatformMessage(
      String channel, ByteData message) {
    final Completer<ByteData?> completer = Completer<ByteData?>();
    ui.window.sendPlatformMessage(channel, message, (ByteData? reply) {
      try {
        completer.complete(reply);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context:
              ErrorDescription('during a platform message response callback'),
        ));
      }
    });
    return completer.future;
  }

  ///
  /// 添加自定义键盘事件
  ///
  static void addKeyboard(CKTextInputType inputType, KeyboardConfig config) {
    _keyboards[inputType] = config;
  }

  ///
  /// 打开键盘
  ///
  static void openKeyboard() {
    var keyboardHeight = _currentKeyboard!.getHeight(_context!);
    _keyboardHeightNotifier.value = keyboardHeight;
    if (_root!.hasKeyboard && _pageKey != null) return;
    _pageKey = GlobalKey<KeyboardPageState>();
    // KeyboardMediaQueryState queryState = _context
    //         .ancestorStateOfType(const TypeMatcher<KeyboardMediaQueryState>())
    //     as KeyboardMediaQueryState;
    // queryState.update();

    var tempKey = _pageKey;
    var isUpdate = false;
    // 在根试图中设置键盘 widget
    _root!.setKeyboard((ctx) {
      if (_currentKeyboard != null && _keyboardHeightNotifier.value != 0) {
        if (!isUpdate) {
          isUpdate = true;
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   _keyboardController!.addText('1');
          // });
        }
        return KeyboardPage(
            key: tempKey,
            builder: (ctx) {
              return _currentKeyboard?.builder(
                  ctx, _keyboardController!, _keyboardParam);
            },
            height: _keyboardHeightNotifier.value);
      } else {
        return Container();
      }
    });

    // 监听物理返回键
    BackButtonInterceptor.add((_, __) {
      CoolKeyboard.sendPerformAction(TextInputAction.done);
      return true;
    }, zIndex: 1, name: 'CustomKeyboard');
  }

  ///
  /// 隐藏键盘
  ///
  static void hideKeyboard({bool animation = true}) {
    if (clearTask != null) {
      if (clearTask!.isActive) {
        clearTask!.cancel();
      }
      clearTask = null;
    }
    BackButtonInterceptor.removeByName('CustomKeyboard');
    if (_root!.hasKeyboard && _pageKey != null) {
      // _pageKey.currentState.animationController
      //     .addStatusListener((AnimationStatus status) {
      //   if (status == AnimationStatus.dismissed ||
      //       status == AnimationStatus.completed) {
      //     if (_root.hasKeyboard) {
      //       _keyboardEntry.remove();
      //       _keyboardEntry = null;
      //     }
      //   }
      // });
      if (animation) {
        _pageKey!.currentState?.exitKeyboard();
        Future.delayed(const Duration(milliseconds: 116)).then((_) {
          // 在根试图中清除键盘 widget
          _root!.clearKeyboard();
        });
      } else {
        // 在根试图中清除键盘 widget
        _root!.clearKeyboard();
      }
    }
    _pageKey = null;
    _keyboardHeightNotifier.value = 0;
    try {
      // KeyboardMediaQueryState queryState = _context
      //     .ancestorStateOfType(const TypeMatcher<KeyboardMediaQueryState>())
      // as KeyboardMediaQueryState;
      // queryState.update();
    } catch (_) {}
  }

  ///
  /// 清除键盘设置
  ///
  static void clearKeyboard() {
    _currentKeyboard = null;
    if (_keyboardController != null) {
      _keyboardController!.dispose();
      _keyboardController = null;
    }
  }

  static void sendPerformAction(TextInputAction action) {
    var callbackMethodCall = MethodCall("TextInputClient.performAction",
        [_keyboardController!.client.connectionId, action.toString()]);

    WidgetsBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
        "flutter/textinput",
        codec.encodeMethodCall(callbackMethodCall),
        (data) {});
  }

  ///
  /// 更新键盘高度
  ///
  static void updateKeyboardHeight() {
    if (_pageKey != null &&
        _pageKey!.currentState != null &&
        clearTask == null) {
      _pageKey!.currentState!.updateHeight(_keyboardHeightNotifier.value);
    }
  }
}

///
/// 保存键盘的配置（键盘 widget 和 键盘高度）
///
class KeyboardConfig {
  final KeyboardBuilder builder;

  // 键盘高度
  final GetKeyboardHeight getHeight;

  const KeyboardConfig({required this.builder, required this.getHeight});
}

class InputClient {
  final int connectionId;
  final TextInputConfiguration configuration;

  const InputClient({required this.connectionId, required this.configuration});

  factory InputClient.fromJSON(List<dynamic> encoded) {
    return InputClient(
        connectionId: encoded[0],
        configuration: TextInputConfiguration(
            inputType: CKTextInputType.fromJSON(encoded[1]['inputType']),
            obscureText: encoded[1]['obscureText'],
            autocorrect: encoded[1]['autocorrect'],
            actionLabel: encoded[1]['actionLabel'],
            inputAction: _toTextInputAction(encoded[1]['inputAction']),
            textCapitalization:
                _toTextCapitalization(encoded[1]['textCapitalization']),
            keyboardAppearance:
                _toBrightness(encoded[1]['keyboardAppearance'])));
  }

  static TextInputAction _toTextInputAction(String action) {
    switch (action) {
      case 'TextInputAction.none':
        return TextInputAction.none;
      case 'TextInputAction.unspecified':
        return TextInputAction.unspecified;
      case 'TextInputAction.go':
        return TextInputAction.go;
      case 'TextInputAction.search':
        return TextInputAction.search;
      case 'TextInputAction.send':
        return TextInputAction.send;
      case 'TextInputAction.next':
        return TextInputAction.next;
      case 'TextInputAction.previuos':
        return TextInputAction.previous;
      case 'TextInputAction.continue_action':
        return TextInputAction.continueAction;
      case 'TextInputAction.join':
        return TextInputAction.join;
      case 'TextInputAction.route':
        return TextInputAction.route;
      case 'TextInputAction.emergencyCall':
        return TextInputAction.emergencyCall;
      case 'TextInputAction.done':
        return TextInputAction.done;
      case 'TextInputAction.newline':
        return TextInputAction.newline;
    }
    throw FlutterError('Unknown text input action: $action');
  }

  static TextCapitalization _toTextCapitalization(String capitalization) {
    switch (capitalization) {
      case 'TextCapitalization.none':
        return TextCapitalization.none;
      case 'TextCapitalization.characters':
        return TextCapitalization.characters;
      case 'TextCapitalization.sentences':
        return TextCapitalization.sentences;
      case 'TextCapitalization.words':
        return TextCapitalization.words;
    }

    throw FlutterError('Unknown text capitalization: $capitalization');
  }

  static Brightness _toBrightness(String brightness) {
    switch (brightness) {
      case 'Brightness.dark':
        return Brightness.dark;
      case 'Brightness.light':
        return Brightness.light;
    }

    throw FlutterError('Unknown Brightness: $brightness');
  }
}

///
/// 自定义文本输入类型
///
class CKTextInputType extends TextInputType {
  final String name;
  final String? params;

  const CKTextInputType(
      {required this.name, bool? signed, bool? decimal, this.params})
      : super.numberWithOptions(signed: signed, decimal: decimal);

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'signed': signed,
      'decimal': decimal,
      'params': params
    };
  }

  @override
  String toString() {
    return '$runtimeType('
        'name: $name, '
        'signed: $signed, '
        'decimal: $decimal)';
  }

  @override
  bool operator ==(Object target) {
    if (target is CKTextInputType) {
      if (name == target.toString()) {
        return true;
      }
    }
    return false;
  }

  @override
  int get hashCode => toString().hashCode;

  factory CKTextInputType.fromJSON(Map<String, dynamic> encoded) {
    return CKTextInputType(
        name: encoded['name'],
        signed: encoded['signed'],
        decimal: encoded['decimal'],
        params: encoded['params']);
  }
}

///
/// 键盘 widget
///
class KeyboardPage extends StatefulWidget {
  final Widget? Function(BuildContext context) builder;
  // 键盘高度
  final double height;

  const KeyboardPage({required this.builder, this.height = 0, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => KeyboardPageState();
}

class KeyboardPageState extends State<KeyboardPage> {
  Widget? _lastBuildWidget;
  bool isClose = false;
  double _height = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _height = widget.height;
      setState(() => {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: 0,
      width: ScreenUtil.getScreenW(context),
      bottom: _height * (isClose ? -1 : 0),
      height: _height,
      duration: const Duration(milliseconds: 100),
      child: IntrinsicHeight(child: Builder(
        builder: (ctx) {
          var result = widget.builder(ctx);
          if (result != null) {
            _lastBuildWidget = result;
          }
          return ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: 0,
                minWidth: 0,
                maxHeight: _height,
                maxWidth: ScreenUtil.getScreenW(context)),
            child: _lastBuildWidget,
          );
        },
      )),
    );
  }

  @override
  void dispose() {
    // if (animationController.status == AnimationStatus.forward ||
    //     animationController.status == AnimationStatus.reverse) {
    //   animationController.notifyStatusListeners(AnimationStatus.dismissed);
    // }
    // animationController.dispose();
    super.dispose();
  }

  ///
  /// 退出键盘
  ///
  void exitKeyboard() {
    isClose = true;
  }

  ///
  /// 跟新键盘
  ///
  void update() {
    // 当前帧渲染完成后执行一个回调函数
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => {});
    });
  }

  ///
  /// 更新键盘高度
  ///
  void updateHeight(double height) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _height = height;
      setState(() => {});
    });
  }
}
