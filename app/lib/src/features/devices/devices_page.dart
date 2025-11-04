import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ble_chat_flutter/src/core/ble/core_ble.dart';
import 'package:ble_chat_flutter/src/core/domain/core_domain.dart';
import 'package:ble_chat_flutter/src/core/storage/storage.dart';

class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({super.key});

  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage> {
  final List<String> _devices = <String>[];
  late final ProviderSubscription<AsyncValue<BleEventDto>> _bleSubscription;

  String _formatTimestamp(DateTime ts) {
    final local = ts.toLocal();
    final hours = local.hour.toString().padLeft(2, '0');
    final minutes = local.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  void initState() {
    super.initState();
    _bleSubscription = ref.listenManual<AsyncValue<BleEventDto>>(
      bleEventsProvider,
      (previous, next) {
        next.whenData((event) {
          if (event.type == 'scan_result' && !_devices.contains(event.deviceId)) {
            if (!mounted) return;
            setState(() {
              _devices.add(event.deviceId);
            });
          }
        });
      },
    );
    ref.read(bleControllerProvider.notifier).scan();
  }

  @override
  void dispose() {
    _bleSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final conversations = conversationsAsync.value ?? const <ConversationDto>[];

    return Scaffold(
      appBar: AppBar(title: const Text('BLE devices')),
      body: ListView(
        children: [
          if (conversationsAsync.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
            ),
          if (conversationsAsync.hasError)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error: ${conversationsAsync.error}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ),
          if (conversations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Conversations',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          for (final conversation in conversations)
            ListTile(
              title: Text(conversation.title ?? conversation.peerId),
              subtitle: Text(
                'Last updated: ${_formatTimestamp(conversation.updatedAt)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: conversation.unread > 0
                  ? CircleAvatar(
                      radius: 12,
                      child: Text(
                        '${conversation.unread}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                      ),
                    )
                  : null,
              onTap: () {
                context.go('/chat?peer=${conversation.peerId}');
              },
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Devices',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (_devices.isEmpty)
            const ListTile(
              title: Text('No devices found'),
              subtitle: Text('No devices found. Please scan for devices.'),
            ),
          for (final deviceId in _devices)
            ListTile(
              title: Text(deviceId),
              onTap: () async {
                await ref.read(bleControllerProvider.notifier).connect(deviceId);
                if (!mounted) return;
                context.go('/chat?peer=$deviceId');
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

  