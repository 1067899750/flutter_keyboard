import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'keyboards/cool_ui.dart';

class CustomKeyboardDemo extends StatefulWidget {
  const CustomKeyboardDemo({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CustomKeyboardDemoState();
  }
}

class CustomKeyboardDemoState extends State<CustomKeyboardDemo> {
  TextEditingController textEditingController =
      TextEditingController(text: 'test');
  TextEditingController textEditing2Controller =
      TextEditingController(text: 'test');

  @override
  Widget build(BuildContext context) {
    return KeyboardMediaQuery(child: Builder(builder: (ctx) {
      // CoolKeyboard.init(ctx);
      return Scaffold(
          appBar: AppBar(
            title: Text("Custom Keyboard Demo"),
          ),
          body: ListView(
            children: <Widget>[
              TextField(
                controller: textEditingController,
                keyboardType: TextInputType.text,
              ),
              Container(
                height: 300,
              ),
              MaterialButton(
                child: Text('弹出功能演示'),
                onPressed: () {
                  showInputDialogs(
                      context: context,
                      messageWidget: Text('弹出输入功能演示'),
                      keyboardType: BoardTypeUtil.cardNumberType);
                },
              ),
              TextField(
                controller: textEditing2Controller,
                decoration: InputDecoration(labelText: '演示键盘弹出后滚动'),
                keyboardType: BoardTypeUtil.cardNumberType,
              ),
              TextField(
                decoration: InputDecoration(labelText: '多个键盘演示'),
                keyboardType: BoardTypeUtil.cardNumberType,
              ),
              TextField(
                decoration: InputDecoration(labelText: '手机号键盘'),
                keyboardType: BoardTypeUtil.phoneType,
              )
            ],
          ));
    }));
  }

  static Future<String?> showInputDialogs(
      {required BuildContext context,
      Widget? titleWidget,
      Widget? messageWidget,
      List<TextInputFormatter>? inputFormatters,
      TextInputType keyboardType = TextInputType.number}) {
    String? value;
    return showCupertinoDialog<String>(
        context: context,
        builder: (context) {
//       The minimum insets for contents of the Scaffold to keep visible.
          List<Widget> children = [];
          if (messageWidget != null) {
            children.add(messageWidget);
          }
          children.add(Form(
              child: Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Material(
                      child: Column(
                    children: <Widget>[
                      TextField(
                        inputFormatters: inputFormatters,
                        keyboardType: keyboardType,
                        autofocus: true,
                        onChanged: (newValue) {
                          value = newValue;
                        },
                      ),
                      TextField(
                        inputFormatters: inputFormatters,
                        keyboardType: TextInputType.text,
                        onChanged: (newValue) {
                          value = newValue;
                        },
                      ),
                      TextField(
                        inputFormatters: inputFormatters,
                        keyboardType: keyboardType,
                        onChanged: (newValue) {
                          value = newValue;
                        },
                      )
                    ],
                  )))));
          return CupertinoAlertDialog(
            title: titleWidget,
            content: Column(
              children: children,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("取消"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: Text("確認"),
                onPressed: () {
                  Navigator.of(context).pop(value ?? '');
                },
              )
            ],
          );
        });
  }
}
