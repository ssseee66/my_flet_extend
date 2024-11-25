import 'package:flet/flet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_pda_scanner/my_pda_scanner_mixin.dart';
import 'package:my_pda_scanner/my_pda_scanner_util.dart';

class PdaListener extends StatefulWidget {
  final Control? parent;
  final Control control;
  final FletControlBackend backend;

  const PdaListener(
      {super.key, this.parent, required this.control, required this.backend});
  @override
  _PdaListener createState() => _PdaListener();
}

class _PdaListener extends State<PdaListener>
    with MyPdaScannerMixin<PdaListener> {
  String _pda_code = "";
  bool _start_listener = false;
  // int _event_count = 0;
  late TextEditingController _controller;
  MyPdaScannerUtil pdaScannerUtil = MyPdaScannerUtil();

  // MyPdaScannerUtil pdaScannerUtil = MyPdaScannerUtil();

  @override
  Widget build(BuildContext context) {
    var pda_code = widget.control.attrString("pda_code");
    _controller = TextEditingController();
    // if (_pda_code != pda_code) {
    //   pda_code = _pda_code;
    //   _controller.text = _pda_code;
    // }
    if (_pda_code != "") {
      pda_code = _pda_code;
      _controller.text = _pda_code;
      // widget.backend
      // .updateControlState(widget.control.id, {"pda_code": pda_code});
    }
    var pda_action = widget.control.attrString("pda_action");
    var data_tag = widget.control.attrString("data_tag");
    var hint_text = widget.control.attrString("hint_text");
    // 测试时为观察事件数量创建的变量
    // var event_count = widget.control.attrInt("event_count");

    bool onChange = widget.control.attrBool("onChange", false)!;
    bool start_listener = widget.control.attrBool("start_listener")!;
    pdaScannerUtil.sendMessageToAndroid(pda_action!, data_tag!);
    final ValueChanged<String>? _on_changed;
    if (start_listener) {
      setState(() {
        _start_listener = true;
      });
    } else {
      setState(() {
        _start_listener = false;
      });
    }

    Widget pda_control = TextField(
        controller: _controller,
        decoration: InputDecoration(
          border: InputBorder.none, //无边框
          hintText: hint_text, //提示文本
        ),
        onChanged: (String value) {
          debugPrint(value);
          _pda_code = value;
          widget.backend
              .updateControlState(widget.control.id, {"pda_code": value});
          if (onChange) {
            widget.backend
                .triggerControlEvent(widget.control.id, "change", value);
          }
        });

    return constrainedControl(
        context, pda_control, widget.parent, widget.control);
  }

  @override
  Future<void> myPdaScannerCodeHandle(String code) async {
    // 编写你的逻辑
    if (_start_listener) {
      setState(() {
        _pda_code = code;
      });
      widget.backend.updateControlState(widget.control.id, {"pda_code": code});
      widget.backend.triggerControlEvent(widget.control.id, "listener", code);
    }
  }
}
