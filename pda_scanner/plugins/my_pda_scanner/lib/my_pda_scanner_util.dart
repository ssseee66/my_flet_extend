import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyPdaScannerUtil {
  MyPdaScannerUtil._();

  factory MyPdaScannerUtil() => _instance;
  static final MyPdaScannerUtil _instance = MyPdaScannerUtil._();
  bool showLog = true;

  EventChannel eventChannel = EventChannel('my_pda_channel');
  MethodChannel flutterChannel = MethodChannel("flutter_to_android");

  void printLog(dynamic log) {
    if (showLog) {
      debugPrint('商米: $log');
    }
  }

  StreamSubscription? streamSubscription;
  Stream? stream;

  Stream start() {
    stream ??= eventChannel.receiveBroadcastStream();
    return stream!;
  }

  /// 监听扫码数据
  void listen(ValueChanged<String> codeHandle) {
    streamSubscription = start().listen((event) {
      if (event != null) {
        printLog('扫描到数据$event');
        codeHandle.call(event.toString());
      }
    });
  }

  void sendMessageToAndroid(String pda_action, String data_tag) async {
    try {
      await flutterChannel.invokeMapMethod(
          "sendMessage", {'pda_action': pda_action, 'data_tag': data_tag});
    } catch (e) {
      print('Error: $e');
    }
  }

  /// 关闭监听
  void cancel() {
    streamSubscription?.cancel();
  }
}
