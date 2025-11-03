import 'package:flutter/material.dart';

import 'package:monorepo/src/app/app.dart';
import 'package:monorepo/src/core/foreground/foreground.dart';
import 'package:monorepo/src/core/notifications/notifications.dart';
import 'package:monorepo/src/core/storage/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  await Notifications.init();
  await Foreground.ensureStarted(); // Android 前台
  runApp(const MyApp());
}
