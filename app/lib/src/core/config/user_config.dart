import 'package:ble_chat_flutter/src/core/domain/models/local_user.dart';

/// Static configuration for locally authorized users.
class UserConfig {
  const UserConfig._();

  static const List<LocalUser> authorizedUsers = <LocalUser>[
    LocalUser(
      username: 'zzy',
      phoneNumber: '13800138000',
      password: '123456',
    ),
    LocalUser(
      username: 'codex_admin',
      phoneNumber: '15500001111',
      password: 'Admin#2024',
    ),
  ];
}
