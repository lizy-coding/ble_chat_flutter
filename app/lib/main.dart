import 'package:ble_chat_flutter/src/core/storage/storage.dart';
import 'package:flutter/material.dart';

import 'package:ble_chat_flutter/src/app/app.dart';
import 'package:ble_chat_flutter/src/core/foreground/foreground.dart';
import 'package:ble_chat_flutter/src/core/notifications/notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  await Notifications.init();
  await Foreground.ensureStarted(); // Android 鍓嶅彴
  runApp(const MyApp());
}

