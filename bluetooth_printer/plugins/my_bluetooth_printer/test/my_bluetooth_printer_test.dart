import 'package:flutter_test/flutter_test.dart';
import 'package:my_bluetooth_printer/my_bluetooth_printer.dart';
import 'package:my_bluetooth_printer/my_bluetooth_printer_platform_interface.dart';
import 'package:my_bluetooth_printer/my_bluetooth_printer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMyBluetoothPrinterPlatform
    with MockPlatformInterfaceMixin
    implements MyBluetoothPrinterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MyBluetoothPrinterPlatform initialPlatform = MyBluetoothPrinterPlatform.instance;

  test('$MethodChannelMyBluetoothPrinter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMyBluetoothPrinter>());
  });

  test('getPlatformVersion', () async {
    MyBluetoothPrinter myBluetoothPrinterPlugin = MyBluetoothPrinter();
    MockMyBluetoothPrinterPlatform fakePlatform = MockMyBluetoothPrinterPlatform();
    MyBluetoothPrinterPlatform.instance = fakePlatform;

    expect(await myBluetoothPrinterPlugin.getPlatformVersion(), '42');
  });
}
