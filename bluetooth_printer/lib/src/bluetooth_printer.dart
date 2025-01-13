import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'package:my_bluetooth_printer/my_bluetooth_printer_util.dart';
import 'package:my_bluetooth_printer/my_bluetooth_printer_mixin.dart';

class BluetoothPrinter extends StatefulWidget {
  final Control? parent;
  final Control control;
  final FletControlBackend backend;

  const BluetoothPrinter(
      {super.key, this.parent, required this.control, required this.backend});
  @override
  _Bluetooth createState() => _Bluetooth();
}

class _Bluetooth extends State<BluetoothPrinter> with MyBluetoothPrinterMixin<BluetoothPrinter>{
  late TextEditingController _controller;
  String _string = "";
  bool _set_channel_name = true;
  // bool _start_scan = false;
  // bool _isConnect = false;
  // late List<String> _bluetooth_list;
  // late int _connect_message = 0;
  MyBluetoothPrinterUtil myBluetoothUtil = MyBluetoothPrinterUtil();

  @override
  Widget build(BuildContext context) {
    var channel_name = widget.control.attrString("channel_name");
    if (_set_channel_name && channel_name != null) {
      myBluetoothUtil.setMessageChannel(channel_name, listenerAndroidHandle);
      myBluetoothUtil.sendChannelName("channelName", channel_name);
      setState(() {
        _set_channel_name = false;
      });
    }
    var message_tag = widget.control.attrString("message_tag");
    var start_scan = widget.control.attrBool("start_scan")!;
    var stop_scan = widget.control.attrBool("stop_scan")!;
    var start_connect = widget.control.attrBool("start_connect")!;
    var close_connect = widget.control.attrBool("close_connect")!;
    var start_send = widget.control.attrBool("start_send")!;
    var address = widget.control.attrString("address");
    var send_data = widget.control.attrString("send_data");
    var bluetooth_list = widget.control.attrString("bluetooth_list");
    var connect_message = widget.control.attrString("connect_message");
    var connect_response = widget.control.attrString("connect_response");
    var data_response = widget.control.attrString("data_response");
    var scan_message = widget.control.attrString("scan_message");
    
    if (start_scan) {     // 开始扫描标志为True时向Android端发送对应信息
      myBluetoothUtil.sendMessageToAndroid("startScan", true);
      setState(() {
        /*
          发送完消息后将开始扫描标志置为“false”（目前只掌握更新字符串属性方式，
          不过影响不大python控件那边布尔型属性可以接受字符串）
          下方多个标志一样的处理方式
        */
        widget.backend.updateControlState(widget.control.id, {"start_scan": "false"});
      });
    } 
    if (stop_scan)  {
      myBluetoothUtil.sendMessageToAndroid("stopScan", true);
      setState(() {
        widget.backend.updateControlState(widget.control.id, {"stop_scan": "false"});
      });
    }
    if (start_connect && address != "") {    // 连接设备标志
      myBluetoothUtil.sendMessageToAndroid("startConnect", address);
      setState(() {
        widget.backend.updateControlState(widget.control.id, {"start_connect": "false"});
      });
    }
    if (close_connect) {    // 关闭设备连接标志
      myBluetoothUtil.sendMessageToAndroid("closeConnect", true);
      setState(() {
        widget.backend.updateControlState(widget.control.id, {"close_connect": "false"});
      });
    }
    if (start_send) {
      myBluetoothUtil.sendMessageToAndroid("startSend", send_data);
      setState(() {
        widget.backend.updateControlState(widget.control.id, {"start_send": "false"});
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
    var connectResponse = message["connectResponse"];
    if (connectResponse != null) {
      // 连接回传数据
      widget.backend.updateControlState(widget.control.id, {"connect_response": connectResponse});
      String eventString = connectResponse;
      widget.backend.updateControlState(widget.control.id, {"message_tag": "connect_response"});
      widget.backend.triggerControlEvent(widget.control.id, "on_listener", eventString);
      setState(() {
        _string = eventString;
      });
    }
    var dataResponse = message["dataResponse"];
    if (dataResponse != null) {
      // 数据回传信息
      widget.backend.updateControlState(widget.control.id, {"data_response": dataResponse});
      String eventString = dataResponse;
      widget.backend.updateControlState(widget.control.id, {"message_tag": "data_response"});
      widget.backend.triggerControlEvent(widget.control.id, "on_listener", eventString);
      setState(() {
        _string = eventString;
      });
    }
    // 设备列表
    var bluetoothList = message["bluetooth_list"];
    if (bluetoothList != null) {
      String eventString = "";
      for (String bluetooth in bluetoothList) {
        eventString += "$bluetooth&";
      }
      widget.backend.updateControlState(widget.control.id, {"bluetooth_list": eventString});
      widget.backend.updateControlState(widget.control.id, {"message_tag": "bluetooth_list"});
      widget.backend.triggerControlEvent(widget.control.id, "on_listener", eventString);
      setState(() {
        _string = eventString;
      });
    }
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
    var scanMessage = message["scanMessage"];
    if (scanMessage != null) {
      widget.backend.updateControlState(widget.control.id, {"scan_message": scanMessage});
      String eventString = scanMessage;
      widget.backend.updateControlState(widget.control.id, {"message_tag": "scan_message"});
      widget.backend.triggerControlEvent(widget.control.id, "on_listener", eventString);
      setState(() {
        _string = eventString;
      });
    }
  }
}

