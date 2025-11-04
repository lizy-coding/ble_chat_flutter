import 'dart:async';
import 'dart:collection';

import 'package:ble_chat_flutter/src/core/domain/core_domain.dart';
import 'package:riverpod/riverpod.dart';

class Storage {
  Storage._();

  static final _messageControllers = <String, StreamController<List<MessageDto>>>{};
  static final _messagesByPeer = HashMap<String, List<MessageDto>>();
  static StreamController<List<ConversationDto>>? _conversationController;
  static final _conversationsByPeer = HashMap<String, ConversationDto>();
  static UserDto? _cachedUser;

  static Future<void> init() async {
    for (final controller in _messageControllers.values) {
      await controller.close();
    }
    _messageControllers.clear();
    _messagesByPeer.clear();
    await _conversationController?.close();
    _conversationController = null;
    _conversationsByPeer.clear();
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

  static Stream<List<ConversationDto>> watchConversations() {
    return _conversationControllerFor().stream;
  }

  static Future<void> ensureConversation(String peerId, {String? title}) async {
    if (_conversationsByPeer.containsKey(peerId)) {
      return;
    }
    _conversationsByPeer[peerId] = ConversationDto(
      peerId: peerId,
      title: title,
      unread: 0,
      updatedAt: DateTime.now(),
    );
    _emitConversations();
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

  static Future<void> markConversationRead(String peerId) async {
    final existing = _conversationsByPeer[peerId];
    if (existing == null || existing.unread == 0) {
      return;
    }
    _conversationsByPeer[peerId] = ConversationDto(
      peerId: peerId,
      title: existing.title,
      unread: 0,
      updatedAt: existing.updatedAt,
    );
    _emitConversations();
  }

  static void _addMessage(String peerId, MessageDto dto) {
    final messages = _messagesByPeer.putIfAbsent(peerId, () => <MessageDto>[]);
    messages.add(dto);
    messages.sort((a, b) => b.ts.compareTo(a.ts));
    final controller = _messageControllers[peerId];
    controller?.add(List.unmodifiable(messages));
    _touchConversation(peerId, dto);
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

  static StreamController<List<ConversationDto>> _conversationControllerFor() {
    return _conversationController ??= () {
      late final StreamController<List<ConversationDto>> controller;
      controller = StreamController<List<ConversationDto>>.broadcast(
        onListen: () {
          controller.add(List.unmodifiable(_conversationSnapshot()));
        },
      );
      return controller;
    }();
  }

  static void _touchConversation(String peerId, MessageDto latest) {
    final existing = _conversationsByPeer[peerId];
    final unread = latest.direction == MessageDirection.in_
        ? (existing?.unread ?? 0) + 1
        : (existing?.unread ?? 0);
    _conversationsByPeer[peerId] = ConversationDto(
      peerId: peerId,
      title: existing?.title ?? peerId,
      unread: unread,
      updatedAt: latest.ts,
    );
    _emitConversations();
  }

  static List<ConversationDto> _conversationSnapshot() {
    final snapshot = _conversationsByPeer.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return snapshot;
  }

  static void _emitConversations() {
    final controller = _conversationController;
    if (controller == null || controller.isClosed) {
      return;
    }
    controller.add(List.unmodifiable(_conversationSnapshot()));
  }

  static String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}

final conversationsProvider = StreamProvider<List<ConversationDto>>(
  (ref) => Storage.watchConversations(),
);

final messagesProvider = StreamProvider.family<List<MessageDto>, String>(
  (ref, peerId) => Storage.watchMessages(peerId),
);

