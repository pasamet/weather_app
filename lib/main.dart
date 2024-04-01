import 'package:flutter/widgets.dart';

import 'src/app/app.dart';
import 'src/app/configuration.dart';
import 'src/app/di.dart';

void main() async {
  await setupDependencies(defaultConfiguration);
  runApp(const App());
}
