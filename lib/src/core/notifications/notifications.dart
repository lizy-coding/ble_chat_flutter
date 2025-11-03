import 'package:flutter/foundation.dart';

class Notifications {
  Notifications._();

  static Future<void> init() async {
    debugPrint('[Notifications] init');
  }

  static Future<void> show(String title, String body) async {
    debugPrint('[Notifications] $title -> $body');
  }
}
