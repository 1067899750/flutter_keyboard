part of cool_ui;

//Copy By TestDefaultBinaryMessenger

class MockBinaryMessenger extends BinaryMessenger {
  /// Creates a [MockBinaryMessenger] instance.
  ///
  MockBinaryMessenger(this.mockBinding);

  /// 用于获取delegate
  final MockBinding mockBinding;

  // The handlers for messages from the engine (including fake
  // messages sent by handlePlatformMessage).
  final Map<String, MessageHandler> _inboundHandlers =
      <String, MessageHandler>{};

  ///
  /// 处理来自平台的消息
  ///
  @override
  Future<ByteData?> handlePlatformMessage(
    String channel,
    ByteData? data,
    ui.PlatformMessageResponseCallback? callback,
  ) {
    Future<ByteData?>? result;
    if (_inboundHandlers.containsKey(channel)) {
      result = _inboundHandlers[channel]!(data);
    }
    result ??= Future<ByteData?>.value(null);
    if (callback != null) {
      result = result.then((ByteData? result) {
        callback(result);
        return result;
      });
    }
    return result;
  }

  ///
  ///  设置处理平台消息的逻辑
  ///
  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    if (handler == null) {
      _inboundHandlers.remove(channel);
      mockBinding._superDefaultBinaryMessenger.setMessageHandler(channel, null);
    } else {
      // used to handle fake messages sent via handlePlatformMessage
      _inboundHandlers[channel] = handler;
      // used to handle real messages from the engine
      mockBinding._superDefaultBinaryMessenger.setMessageHandler(channel, handler);
    }
  }

  final List<Future<ByteData?>> _pendingMessages = <Future<ByteData?>>[];

  /// The number of incomplete/pending calls sent to the platform channels.
  int get pendingMessageCount => _pendingMessages.length;

  // Handlers that intercept and respond to outgoing messages,
  // pretending to be the platform.
  final Map<String, MessageHandler> _outboundHandlers =
      <String, MessageHandler>{};

  // The outbound callbacks that were actually registered, so that we
  // can implement the [checkMockMessageHandler] method.
  final Map<String, Object> _outboundHandlerIdentities = <String, Object>{};

  ///
  /// 实现消息发送逻辑
  ///
  @override
  Future<ByteData?>? send(String channel, ByteData? message) {
    final Future<ByteData?>? resultFuture;
    final MessageHandler? handler = _outboundHandlers[channel];
    if (handler != null) {
      // 执行自定义消息
      resultFuture = handler(message);
    } else {
      // 处理系统消息
      resultFuture =
          mockBinding._superDefaultBinaryMessenger.send(channel, message);
    }
    if (resultFuture != null) {
      _pendingMessages.add(resultFuture);
      resultFuture.catchError((Object error) {
        /* errors are the responsibility of the caller */
      }).whenComplete(() => _pendingMessages.remove(resultFuture));
    }
    return resultFuture;
  }

  /// Returns a Future that completes after all the platform calls are finished.
  ///
  /// If a new platform message is sent after this method is called, this new
  /// message is not tracked. Use with [pendingMessageCount] to guarantee no
  /// pending message calls.
  Future<void> get platformMessagesFinished {
    return Future.wait<void>(_pendingMessages);
  }

  /// Set a callback for intercepting messages sent to the platform on
  /// the given channel, without decoding them.
  ///
  /// Intercepted messages are not forwarded to the platform.
  ///
  /// The given callback will replace the currently registered
  /// callback for that channel, if any. To stop intercepting messages
  /// at all, pass null as the handler.
  ///
  /// The handler's return value, if non-null, is used as a response,
  /// unencoded.
  ///
  /// {@macro flutter.flutter_test.MockBinaryMessenger.handlePlatformMessage.asyncHandlers}
  ///
  /// The `identity` argument, if non-null, is used to identify the
  /// callback when checked by [checkMockMessageHandler]. If null, the
  /// `handler` is used instead. (This allows closures to be passed as
  /// the `handler` with an alias used as the `identity` so that a
  /// reference to the closure need not be used. In practice, this is
  /// used by [setMockDecodedMessageHandler] and
  /// [setMockMethodCallHandler] to allow [checkMockMessageHandler] to
  /// recognize the closures that were passed to those methods even
  /// though those methods wrap those closures when passing them to
  /// this method.)
  ///
  /// Registered callbacks are cleared after each test.
  ///
  /// See also:
  ///
  ///  * [checkMockMessageHandler], which can verify if a handler is still
  ///    registered, which is useful in tests to ensure that no unexpected
  ///    handlers are being registered.
  ///
  ///  * [setMockDecodedMessageHandler], which wraps this method but
  ///    decodes the messages using a [MessageCodec].
  ///
  ///  * [setMockMethodCallHandler], which wraps this method but decodes
  ///    the messages using a [MethodCodec].
  ///
  /// 只要用于把消息加入队列中
  ///
  void setMockMessageHandler(String channel, MessageHandler? handler,
      [Object? identity]) {
    if (handler == null) {
      _outboundHandlers.remove(channel);
      _outboundHandlerIdentities.remove(channel);
    } else {
      identity ??= handler;
      _outboundHandlers[channel] = handler;
      _outboundHandlerIdentities[channel] = identity;
    }
  }

  /// Set a callback for intercepting messages sent to the platform on
  /// the given channel.
  ///
  /// Intercepted messages are not forwarded to the platform.
  ///
  /// The given callback will replace the currently registered
  /// callback for that channel, if any. To stop intercepting messages
  /// at all, pass null as the handler.
  ///
  /// Messages are decoded using the codec of the channel.
  ///
  /// The handler's return value, if non-null, is used as a response,
  /// after encoding it using the channel's codec.
  ///
  /// {@macro flutter.flutter_test.MockBinaryMessenger.handlePlatformMessage.asyncHandlers}
  ///
  /// Registered callbacks are cleared after each test.
  ///
  /// See also:
  ///
  ///  * [checkMockMessageHandler], which can verify if a handler is still
  ///    registered, which is useful in tests to ensure that no unexpected
  ///    handlers are being registered.
  ///
  ///  * [setMockMessageHandler], which is similar but provides raw
  ///    access to the underlying bytes.
  ///
  ///  * [setMockMethodCallHandler], which is similar but decodes
  ///    the messages using a [MethodCodec].
  void setMockDecodedMessageHandler<T>(
      BasicMessageChannel<T> channel, Future<T> Function(T? message)? handler) {
    if (handler == null) {
      setMockMessageHandler(channel.name, null);
      return;
    }
    setMockMessageHandler(channel.name, (ByteData? message) async {
      return channel.codec
          .encodeMessage(await handler(channel.codec.decodeMessage(message)));
    }, handler);
  }

  /// Set a callback for intercepting method calls sent to the
  /// platform on the given channel.
  ///
  /// Intercepted method calls are not forwarded to the platform.
  ///
  /// The given callback will replace the currently registered
  /// callback for that channel, if any. To stop intercepting messages
  /// at all, pass null as the handler.
  ///
  /// Methods are decoded using the codec of the channel.
  ///
  /// The handler's return value, if non-null, is used as a response,
  /// after re-encoding it using the channel's codec.
  ///
  /// To send an error, throw a [PlatformException] in the handler.
  /// Other exceptions are not caught.
  ///
  /// {@macro flutter.flutter_test.MockBinaryMessenger.handlePlatformMessage.asyncHandlers}
  ///
  /// Registered callbacks are cleared after each test.
  ///
  /// See also:
  ///
  ///  * [checkMockMessageHandler], which can verify if a handler is still
  ///    registered, which is useful in tests to ensure that no unexpected
  ///    handlers are being registered.
  ///
  ///  * [setMockMessageHandler], which is similar but provides raw
  ///    access to the underlying bytes.
  ///
  ///  * [setMockDecodedMessageHandler], which is similar but decodes
  ///    the messages using a [MessageCodec].
  void setMockMethodCallHandler(MethodChannel channel,
      Future<Object?>? Function(MethodCall message)? handler) {
    if (handler == null) {
      setMockMessageHandler(channel.name, null);
      return;
    }
    setMockMessageHandler(channel.name, (ByteData? message) async {
      final MethodCall call = channel.codec.decodeMethodCall(message);
      try {
        return channel.codec.encodeSuccessEnvelope(await handler(call));
      } on PlatformException catch (error) {
        return channel.codec.encodeErrorEnvelope(
          code: error.code,
          message: error.message,
          details: error.details,
        );
      } on MissingPluginException {
        return null;
      } catch (error) {
        return channel.codec.encodeErrorEnvelope(
            code: 'error', message: '$error', details: null);
      }
    }, handler);
  }

  /// Returns true if the `handler` argument matches the `handler`
  /// previously passed to [setMockMessageHandler],
  /// [setMockDecodedMessageHandler], or [setMockMethodCallHandler].
  ///
  /// Specifically, it compares the argument provided to the `identity`
  /// argument provided to [setMockMessageHandler], defaulting to the
  /// `handler` argument passed to that method is `identity` was null.
  ///
  /// This method is useful for tests or test harnesses that want to assert the
  /// mock handler for the specified channel has not been altered by a previous
  /// test.
  ///
  /// Passing null for the `handler` returns true if the handler for the
  /// `channel` is not set.
  ///
  /// Registered callbacks are cleared after each test.
  bool checkMockMessageHandler(String channel, Object? handler) =>
      _outboundHandlerIdentities[channel] == handler;
}
