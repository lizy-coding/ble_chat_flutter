import 'package:flutter/foundation.dart';

class Foreground {
  Foreground._();

  static Future<void> ensureStarted() async {
    debugPrint('[Foreground] ensureStarted');
  }
}

