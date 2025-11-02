library core_storage;

import 'dart:async';
import 'dart:collection';

import 'package:core_domain/core_domain.dart';

class Storage {
  Storage._();

  static final _messageControllers = <String, StreamController<List<MessageDto>>>{};
  static final _messagesByPeer = HashMap<String, List<MessageDto>>();
  static UserDto? _cachedUser;

  static Future<void> init() async {
    for (final controller in _messageControllers.values) {
      await controller.close();
    }
    _messageControllers.clear();
    _messagesByPeer.clear();
    _cachedUser = null;
  }

  static Future<UserDto> ensureUser() async {
    final current = _cachedUser;
    if (current != null) {
      return current;
    }

    final now = DateTime.now();
    final user = UserDto(
      uid: now.millisecondsSinceEpoch.toString(),
      createdAt: now,
    );
    _cachedUser = user;
    return user;
  }

  static Stream<List<MessageDto>> watchMessages(String peerId) {
    return _controllerFor(peerId).stream;
  }

  static Future<MessageDto> insertOutgoing(String peerId, String text) async {
    final dto = MessageDto(
      id: _newId(),
      peerId: peerId,
      direction: MessageDirection.out,
      text: text,
      ts: DateTime.now(),
      status: MessageStatus.sent,
    );
    _addMessage(peerId, dto);
    return dto;
  }

  static Future<MessageDto> insertIncoming(String peerId, String text) async {
    final dto = MessageDto(
      id: _newId(),
      peerId: peerId,
      direction: MessageDirection.in_,
      text: text,
      ts: DateTime.now(),
      status: MessageStatus.delivered,
    );
    _addMessage(peerId, dto);
    return dto;
  }

  static void _addMessage(String peerId, MessageDto dto) {
    final messages = _messagesByPeer.putIfAbsent(peerId, () => <MessageDto>[]);
    messages.add(dto);
    messages.sort((a, b) => b.ts.compareTo(a.ts));
    final controller = _messageControllers[peerId];
    controller?.add(List.unmodifiable(messages));
  }

  static StreamController<List<MessageDto>> _controllerFor(String peerId) {
    return _messageControllers.putIfAbsent(peerId, () {
      late final StreamController<List<MessageDto>> controller;
      controller = StreamController<List<MessageDto>>.broadcast(
        onListen: () {
          final snapshot = _messagesByPeer[peerId];
          controller.add(List.unmodifiable(snapshot ?? const <MessageDto>[]));
        },
      );
      return controller;
    });
  }

  static String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
