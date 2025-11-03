import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monorepo/src/core/ble/core_ble.dart';

class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({super.key});

  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage> {
  final List<String> _devices = <String>[];

  @override
  void initState() {
    super.initState();
    ref.read(bleControllerProvider.notifier).scan();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<BleEventDto>>(
      bleEventsProvider,
      (previous, next) {
        next.whenData((event) {
          if (event.type == 'scan_result' && !_devices.contains(event.deviceId)) {
            setState(() {
              _devices.add(event.deviceId);
            });
          }
        });
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('BLE 设备')),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (_, index) {
          final deviceId = _devices[index];
          return ListTile(
            title: Text(deviceId),
            onTap: () async {
              await ref.read(bleControllerProvider.notifier).connect(deviceId);
              if (!mounted) return;
              context.go('/chat?peer=$deviceId');
            },
          );
        },
      ),
    );
  }
}
