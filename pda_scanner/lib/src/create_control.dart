import 'package:flet/flet.dart';
import 'pda_listener.dart';

CreateControlFactory createControl = (CreateControlArgs args) {
  switch (args.control.type) {
    case "pda_listener":
      PdaListener pda_listener = PdaListener(
        parent: args.parent,
        control: args.control,
        backend: args.backend,
      );
      return pda_listener;
    default:
      return null;
  }
};

void ensureInitialized() {
  // nothing to initialize
}
