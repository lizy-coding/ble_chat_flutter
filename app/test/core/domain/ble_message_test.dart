import 'package:ble_chat_flutter/src/core/domain/core_domain.dart';
import 'package:flutter_test/flutter_test.dart'
    show containsAll, equals, expect, group, isA, isNotNull, isTrue, test, throwsA;

void main() {
  group('BleMessage', () {
    final now = DateTime.utc(2024, 1, 1, 12, 30);

    BleMessage buildMessage({DateTime? deliveredAt, DateTime? readAt}) =>
        BleMessage(
          id: '1',
          conversationId: 'conv',
          senderDeviceId: 'sender',
          receiverDeviceId: 'receiver',
          payload: 'Hello',
          createdAt: now,
          deliveredAt: deliveredAt,
          readAt: readAt,
        );

    test('status derives from delivery markers', () {
      expect(buildMessage().status, BleMessageStatus.pending);
      expect(buildMessage(deliveredAt: now).status, BleMessageStatus.delivered);
      expect(
        buildMessage(deliveredAt: now, readAt: now).status,
        BleMessageStatus.read,
      );
    });

    test('payload validation enforces non empty content', () {
      expect(
        () => buildMessage().copyWith(payload: '   '),
        throwsA(isA<MessagePayloadException>()),
      );
    });

    test('payload validation enforces byte limit', () {
      final message = buildMessage();
      final longContent = 'a' * (kDefaultBlePayloadLimit + 1);
      expect(
        () => message.copyWith(payload: longContent),
        throwsA(isA<MessagePayloadException>()),
      );
    });

    test('json serialization uses iso dates', () {
      final deliveredAt = now.add(const Duration(minutes: 1));
      final readAt = now.add(const Duration(minutes: 2));
      final message = buildMessage(
        deliveredAt: deliveredAt,
        readAt: readAt,
      );
      final json = message.toJson();
      expect(json['createdAt'], now.toIso8601String());
      expect(json['deliveredAt'], deliveredAt.toIso8601String());
      expect(json['readAt'], readAt.toIso8601String());
      final restored = BleMessage.fromJson(json);
      expect(restored, equals(message));
    });
  });

  group('BleMessage utilities', () {
    final now = DateTime.utc(2024, 1, 1, 12, 0);
    final messages = List.generate(3, (index) {
      return BleMessage(
        id: '$index',
        conversationId: index == 0 ? 'a' : 'b',
        senderDeviceId: 'sender',
        receiverDeviceId: 'receiver',
        payload: 'message $index',
        createdAt: now.add(Duration(minutes: index)),
      );
    });

    test('sortMessagesByTimestamp sorts ascending by default', () {
      final unordered = [messages[2], messages[0], messages[1]];
      final sorted = sortMessagesByTimestamp(unordered);
      expect(sorted, equals(messages));
    });

    test('sortMessagesByTimestamp supports descending order', () {
      final sorted = sortMessagesByTimestamp(messages, descending: true);
      expect(sorted.first.id, '2');
      expect(sorted.last.id, '0');
    });

    test('groupMessagesByConversation groups using conversationId', () {
      final grouped = groupMessagesByConversation(messages);
      expect(grouped.keys, containsAll(['a', 'b']));
      expect(grouped['a']!.single.id, '0');
      expect(grouped['b']!.length, 2);
    });

    test('latestMessagesPerConversation returns last per group', () {
      final latest = latestMessagesPerConversation(messages);
      expect(latest['a']!.id, '0');
      expect(latest['b']!.id, '2');
    });
  });

  group('BleDevice', () {
    test('copyWith updates selective fields', () {
      final device = BleDevice(id: 'id', name: 'Device');
      final updated = device.copyWith(name: 'Updated', isConnected: true);
      expect(updated.name, 'Updated');
      expect(updated.isConnected, isTrue);
      expect(updated.id, device.id);
    });

    test('json serialization round trips data', () {
      final device = BleDevice(
        id: 'id',
        name: 'Device',
        lastRssi: -45,
        lastSeenAt: DateTime.utc(2024),
        isConnected: true,
      );
      final json = device.toJson();
      expect(json['lastSeenAt'], isNotNull);
      final restored = BleDevice.fromJson(json);
      expect(restored, equals(device));
    });
  });
}

