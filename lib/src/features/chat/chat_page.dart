import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monorepo/src/core/ble/core_ble.dart';
import 'package:monorepo/src/core/domain/core_domain.dart';
import 'package:monorepo/src/core/notifications/notifications.dart';
import 'package:monorepo/src/core/storage/storage.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.peerId});

  final String peerId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<BleEventDto>>(
      bleEventsProvider,
      (previous, next) {
        next.whenData((event) {
          if (event.type == 'notify' && event.payload != null) {
            Notifications.show('新消息', event.payload!);
          }
        });
      },
    );

    final messagesStream = Storage.watchMessages(widget.peerId);
    return Scaffold(
      appBar: AppBar(title: Text('与 ${widget.peerId}')),
      body: StreamBuilder<List<MessageDto>>(
        stream: messagesStream,
        builder: (_, snapshot) {
          final messages = snapshot.data ?? const <MessageDto>[];
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final message = messages[index];
                    final alignment = message.direction == MessageDirection.out
                        ? Alignment.centerRight
                        : Alignment.centerLeft;
                    return Align(
                      alignment: alignment,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(message.text),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        decoration: const InputDecoration(
                          hintText: 'Text...',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final text = _inputController.text.trim();
                        if (text.isEmpty) {
                          return;
                        }
                        _inputController.clear();
                        await ref.read(bleControllerProvider.notifier).send(text);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
