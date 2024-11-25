import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'package:my_rfid_reader/my_rfid_reader_mixin.dart';
import 'package:my_rfid_reader/my_rfid_reader_util.dart';

class RfidReader extends StatefulWidget {
  final Control? parent;
  final Control control;
  final FletControlBackend backend;

  const RfidReader(
      {super.key, this.parent, required this.control, required this.backend});
  @override
  _RfidReader createState() => _RfidReader();
}

class _RfidReader extends State<RfidReader> with MyRfidReaderMixin<RfidReader>{
  late TextEditingController _controller;
  String _string = "";
  MyRfidReaderUtil myRfidReaderUtil = MyRfidReaderUtil();

  @override
  Widget build(BuildContext context) {
    var message_tag = widget.control.attrString("message_tag");
    var start_connect = widget.control.attrBool("start_connect")!;
    // var close_connect = widget.control.attrBool("close_connect")!;
    var turn_on_power = widget.control.attrBool("turn_on_power")!;
    var turn_off_power = widget.control.attrBool("turn_off_power")!;
    var start_reader = widget.control.attrBool("start_reader")!;
    var start_reader_epc = widget.control.attrBool("start_reader_epc")!;
    var start_write_epc = widget.control.attrBool("start_write_epc")!;
    var epc_data = widget.control.attrString("epc_data");
    var epc_data_area = widget.control.attrInt("epc_data_area");
    var connect_message = widget.control.attrString("connect_message");
    var power_message = widget.control.attrString("power_message");
    var reader_operation_message = widget.control.attrString("reader_operation_message");
    var epc_messages = widget.control.attrString("epc_messages");
    var write_epc_message = widget.control.attrString("write_epc_message");


    if (start_connect) {     // 开始扫描标志为True时向Android端发送对应信息
      myRfidReaderUtil.sendMessageToAndroid("startConnect", true);
      setState(() {
        /*
          发送完消息后将开始扫描标志置为“false”（目前只掌握更新字符串属性方式，
          不过影响不大python控件那边布尔型属性可以接受字符串）
          下方多个标志一样的处理方式
        */
        widget.backend.updateControlState(widget.control.id, {"start_connect": "false"});
      });
    }
    if (turn_on_power)  {
      myRfidReaderUtil.sendMessageToAndroid("turnOnPower", true);
      setState(() {
        widget.backend.updateControlState(widget.control.id, {"turn_on_power": "false"});
      });
    }
    if (turn_off_power) {
      myRfidReaderUtil.sendMessageToAndroid("turnOffPower", true);
      setState(() {
        widget.backend.updateControlState(widget.control.id, {"turn_off_power": "false"});
      });
    }
    if (start_reader) {
      myRfidReaderUtil.sendMessageToAndroid("startReader", true);
      setState(() {
        widget.backend.updateControlState(widget.control.id, {"start_reader": "false"});
      });
    }
    if (start_reader_epc) {
      myRfidReaderUtil.sendMessageToAndroid("startReaderEpc", true);
      setState(() {
        widget.backend.updateControlState(widget.control.id, {"start_reader_epc": "false"});
      });
    }
    if (start_write_epc && epc_data != "") {
      String write_epc_data = "";
      if (epc_data != null) {
        write_epc_data = epc_data + "&" + epc_data_area.toString();
      }
      myRfidReaderUtil.sendMessageToAndroid("writeEpcData", write_epc_data);
      setState(() {
        widget.backend.updateControlState(widget.control.id, {"start_write_epc": "false"});
      });
    }
    if (_string != "") {
      _controller.text = _string;
    }
    Widget bluetooth_control = TextField(
        controller: _controller,
        decoration: const InputDecoration(
          border: InputBorder.none, //无边框
        )
    );
    return constrainedControl(
        context, bluetooth_control, widget.parent, widget.control);
  }

  @override
  Future<void> listenerAndroidHandle(dynamic message) async {
    // TODO: implement listenerAndroidHandle
    // 连接结果（连接成功、连接失败、断开连接）消息样式为   连接成功>>>（设备名称）
    var connectMessage = message["connectMessage"];
    if (connectMessage != null) {
      widget.backend.updateControlState(widget.control.id, {"connect_message": connectMessage});
      String eventString = connectMessage;
      widget.backend.updateControlState(widget.control.id, {"message_tag": "connect_message"});
      widget.backend.triggerControlEvent(widget.control.id, "on_listener", eventString);
      setState(() {
        _string = eventString;
      });
    }
    // 读写器读卡操作信息
    var readerOperationMessage = message["readerOperationMessage"];
    if (readerOperationMessage != null) {
      widget.backend.updateControlState(widget.control.id, {"reader_operation_message": readerOperationMessage});
      String eventString = readerOperationMessage;
      widget.backend.updateControlState(widget.control.id, {"message_tag": "reader_operation_message"});
      widget.backend.triggerControlEvent(widget.control.id, "on_listener", eventString);
      setState(() {
        _string = eventString;
      });
    }
    // 读取epc数据
    var epcMessages = message["epcMessages"];
    if (epcMessages != null) {
      String eventString = "";
      for (String epcMessage in epcMessages)  {
        eventString += "$epcMessage&";
      }
      widget.backend.updateControlState(widget.control.id, {"epc_messages": eventString});
      widget.backend.updateControlState(widget.control.id, {"message_tag": "epc_messages"});
      widget.backend.triggerControlEvent(widget.control.id, "on_listener", eventString);
      setState(() {
        _string = eventString;
      });
    }
    // 上下电信息
    var powerMessage = message["powerMessage"];
    if (powerMessage != null) {
      String eventString = powerMessage;
      widget.backend.updateControlState(widget.control.id, {"power_message": eventString});
      widget.backend.updateControlState(widget.control.id, {"message_tag": "power_message"});
      widget.backend.triggerControlEvent(widget.control.id, "on_listener", eventString);
      setState(() {
        _string = eventString;
      });
    }

    // 写卡信息
    var writeEpcMessage = message["writeEpcMessage"];
    if (writeEpcMessage != null) {
      String eventString = writeEpcMessage;
      widget.backend.updateControlState(widget.control.id, {"write_epc_message": eventString});
      widget.backend.updateControlState(widget.control.id, {"message_tag": "write_epc_message"});
      widget.backend.triggerControlEvent(widget.control.id, "on_listener", eventString);
      setState(() {
        _string = eventString;
      });
    }
  }
}

