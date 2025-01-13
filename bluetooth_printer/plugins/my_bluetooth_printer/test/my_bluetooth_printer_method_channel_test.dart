import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_bluetooth_printer/my_bluetooth_printer_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelMyBluetoothPrinter platform = MethodChannelMyBluetoothPrinter();
  const MethodChannel channel = MethodChannel('my_bluetooth_printer');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
