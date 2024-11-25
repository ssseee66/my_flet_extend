// import 'package:bluetooth/src/buletooth.dart';
import 'package:flet/flet.dart';
import 'rfid_reader.dart';

CreateControlFactory createControl = (CreateControlArgs args) {
  switch (args.control.type) {
    case "rfid_reader":
      return RfidReader(
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
