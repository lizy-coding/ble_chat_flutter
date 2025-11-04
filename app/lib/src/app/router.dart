import 'package:go_router/go_router.dart';

import '../features/chat/chat_page.dart';
import '../features/devices/devices_page.dart';

GoRouter buildRouter() => GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const DevicesPage()),
        GoRoute(
          path: '/chat',
          builder: (_, state) => ChatPage(
            peerId: state.uri.queryParameters['peer'] ?? 'device',
          ),
        ),
      ],
    );

