import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'my_bluetooth_printer_util.dart';

mixin MyBluetoothPrinterMixin<T extends StatefulWidget> on State<T> {
  late StreamSubscription streamSubscription;
  final MyBluetoothPrinterUtil util = MyBluetoothPrinterUtil();

  @override
  void initState() {
    super.initState();
    util.flutterChannel.setMessageHandler(listenerAndroidHandle);
  }

  Future<void> listenerAndroidHandle(dynamic message);

}