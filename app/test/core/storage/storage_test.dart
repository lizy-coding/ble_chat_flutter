import 'package:ble_chat_flutter/src/core/domain/core_domain.dart';
import 'package:ble_chat_flutter/src/core/storage/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core_domain/core_domain.dart';

void main() {
  const peerId = 'device-123';

  setUp(() async {
    await Storage.init();
  });

  test('Storage emits messages after insert', () async {
    final messagesFuture = Storage.watchMessages(peerId).skip(1).first;

    await Storage.insertOutgoing(peerId, 'hello');

    final messages = await messagesFuture;
    expect(messages, hasLength(1));
    final message = messages.first;
    expect(message.peerId, peerId);
    expect(message.text, 'hello');
    expect(message.direction, MessageDirection.out);
  });

  test('Storage updates conversation unread count on incoming message', () async {
    final conversationStream = Storage.watchConversations();
    final conversationFuture = conversationStream.skip(1).first;

    await Storage.insertIncoming(peerId, 'hi there');

    final conversations = await conversationFuture;
    expect(conversations, hasLength(1));
    final conversation = conversations.first;
    expect(conversation.peerId, peerId);
    expect(conversation.unread, 1);

    final clearedFuture = conversationStream.firstWhere(
      (snapshot) => snapshot.isNotEmpty && snapshot.first.unread == 0,
    );

    await Storage.markConversationRead(peerId);

    final cleared = await clearedFuture;
    expect(cleared.first.unread, 0);
  });

  test('ensureConversation creates entry without messages', () async {
    final conversationFuture = Storage.watchConversations().skip(1).first;

    await Storage.ensureConversation(peerId, title: 'Peer device');

    final conversations = await conversationFuture;
    expect(conversations, hasLength(1));
    final conversation = conversations.first;
    expect(conversation.peerId, peerId);
    expect(conversation.title, 'Peer device');
    expect(conversation.unread, 0);
  });
}

