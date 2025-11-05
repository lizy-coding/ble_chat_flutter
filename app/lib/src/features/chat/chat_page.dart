import 'package:ble_chat_flutter/src/core/ble/core_ble.dart';
import 'package:ble_chat_flutter/src/core/domain/core_domain.dart';
import 'package:ble_chat_flutter/src/core/localization/localization.dart';
import 'package:ble_chat_flutter/src/core/notifications/notifications.dart';
import 'package:ble_chat_flutter/src/core/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.peerId});

  final String peerId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _inputController = TextEditingController();
  late final ProviderSubscription<AsyncValue<BleEventDto>> _bleSubscription;
  late final ProviderSubscription<AsyncValue<List<MessageDto>>> _messagesSubscription;

  @override
  void initState() {
    super.initState();
    _bleSubscription = ref.listenManual<AsyncValue<BleEventDto>>(
      bleEventsProvider,
      (previous, next) {
        next.whenData((event) {
          if (event.type == 'notify' &&
              event.deviceId == widget.peerId &&
              event.payload != null) {
            if (!mounted) return;
            Notifications.show(context.l10n.notificationNewMessage, event.payload!);
          }
        });
      },
    );
    _messagesSubscription = ref.listenManual<AsyncValue<List<MessageDto>>>(
      messagesProvider(widget.peerId),
      (previous, next) {
        if (next.hasValue) {
          Storage.markConversationRead(widget.peerId);
        }
      },
    );
  }

  @override
  void dispose() {
    _bleSubscription.close();
    _messagesSubscription.close();
    _inputController.dispose();
    super.dispose();
  }

  Widget _buildMessages(List<MessageDto> messages) {
    return ListView.builder(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.peerId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: context.l10n.bleDevicesTitle,
          onPressed: () => context.go('/devices'),
        ),
        title: Text(context.l10n.chatWithPeer(widget.peerId)),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => _buildMessages(messages),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text(context.l10n.messagesLoadFailed('$error')),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: context.l10n.messageInputHint,
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
      ),
    );
  }
}

