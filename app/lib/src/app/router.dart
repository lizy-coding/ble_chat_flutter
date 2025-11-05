import 'package:ble_chat_flutter/src/core/auth/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_page.dart';
import '../features/chat/chat_page.dart';
import '../features/devices/devices_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authController = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authController,
    redirect: (context, state) {
      final isLoggedIn = authController.state.isAuthenticated;
      final loggingIn = state.matchedLocation == '/login';
      if (!isLoggedIn) {
        return loggingIn ? null : '/login';
      }
      if (loggingIn) {
        return '/devices';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/devices',
        builder: (_, __) => const DevicesPage(),
      ),
      GoRoute(
        path: '/chat',
        builder: (_, state) => ChatPage(
          peerId: state.uri.queryParameters['peer'] ?? 'device',
        ),
      ),
    ],
  );
});

