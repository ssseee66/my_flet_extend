// import 'package:bluetooth/src/buletooth.dart';
import 'package:flet/flet.dart';
import 'bluetooth_printer.dart';

CreateControlFactory createControl = (CreateControlArgs args) {
  switch (args.control.type) {
    case "bluetooth_printer":
      return BluetoothPrinter(
        parent: args.parent,
        control: args.control,
        backend: args.backend,
      );
    default:
      return null;
  }
};

void ensureInitialized() {
  // nothing to initialize
}
