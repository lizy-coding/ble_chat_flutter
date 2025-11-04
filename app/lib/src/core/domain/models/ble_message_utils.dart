import 'package:collection/collection.dart';

import 'ble_message.dart';

/// Sorts [messages] by their [BleMessage.createdAt] timestamp.
List<BleMessage> sortMessagesByTimestamp(
  Iterable<BleMessage> messages, {
  bool descending = false,
}) {
  final sorted = messages.toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return descending ? sorted.reversed.toList() : sorted;
}

/// Groups messages by their [BleMessage.conversationId].
Map<String, List<BleMessage>> groupMessagesByConversation(
  Iterable<BleMessage> messages,
) {
  return groupBy(messages, (message) => message.conversationId)
      .map((key, value) => MapEntry(key, sortMessagesByTimestamp(value)));
}

/// Returns only the most recent message per conversation.
Map<String, BleMessage> latestMessagesPerConversation(
  Iterable<BleMessage> messages,
) {
  final grouped = groupMessagesByConversation(messages);
  final latest = <String, BleMessage>{};
  for (final entry in grouped.entries) {
    if (entry.value.isEmpty) {
      continue;
    }
    latest[entry.key] = entry.value.last;
  }
  return latest;
}

