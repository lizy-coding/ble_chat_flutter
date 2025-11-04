import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:ble_chat_flutter/src/core/domain/core_domain.dart';
import 'package:ble_chat_flutter/src/core/storage/storage.dart';


final _bleEventControllerProvider = Provider<StreamController<BleEventDto>>((ref) {
  final controller = StreamController<BleEventDto>.broadcast();
  ref.onDispose(controller.close);
  return controller;
});

final bleEventsProvider = StreamProvider<BleEventDto>((ref) {
  final controller = ref.watch(_bleEventControllerProvider);
  return controller.stream;
});

final bleControllerProvider = StateNotifierProvider<BleController, String?>((ref) {
  final controller = ref.watch(_bleEventControllerProvider);
  return BleController(controller);
});

class BleController extends StateNotifier<String?> {
  BleController(this._events) : super(null);

  final StreamController<BleEventDto> _events;
  bool _hasScanned = false;

  Future<void> scan() async {
    if (_hasScanned) {
      return;
    }
    _hasScanned = true;
    _emit(
      BleEventDto(
        type: 'scan_result',
        deviceId: 'device',
        payload: null,
      ),
    );
  }

  Future<void> connect(String deviceId) async {
    state = deviceId;
    await Storage.ensureConversation(deviceId);
    _emit(
      BleEventDto(
        type: 'connected',
        deviceId: deviceId,
        payload: null,
      ),
    );
  }

  Future<void> send(String text) async {
    final target = state;
    if (target == null || text.isEmpty) {
      return;
    }
    await Storage.insertOutgoing(target, text);
    final response = 'Echo: $text';
    await Storage.insertIncoming(target, response);
    _emit(
      BleEventDto(
        type: 'notify',
        deviceId: target,
        payload: response,
      ),
    );
  }

  void _emit(BleEventDto event) {
    if (!_events.isClosed) {
      _events.add(event);
    }
  }
}

