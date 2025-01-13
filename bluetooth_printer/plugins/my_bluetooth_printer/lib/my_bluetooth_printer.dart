
import 'package:flutter/services.dart';

class MyBluetoothPrinter {
  static const MethodChannel _channel =
  MethodChannel('my_bluetooth_printer');

  static Future<String?> Init() async {
    final String? code = await _channel.invokeMethod('init');
    return code;
  }
}
