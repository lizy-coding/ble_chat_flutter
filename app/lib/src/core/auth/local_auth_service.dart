import 'package:ble_chat_flutter/src/core/config/user_config.dart';
import 'package:ble_chat_flutter/src/core/domain/models/local_user.dart';

class LocalAuthService {
  LocalAuthService({List<LocalUser>? allowedUsers})
      : _allowedUsers = allowedUsers ?? UserConfig.authorizedUsers;

  final List<LocalUser> _allowedUsers;

  LocalUser? authenticate({required String identifier, required String password}) {
    final trimmedIdentifier = identifier.trim();
    final normalizedIdentifier = trimmedIdentifier.toLowerCase();
    final normalizedPassword = password.trim();

    for (final user in _allowedUsers) {
      final usernameMatch = user.username.toLowerCase() == normalizedIdentifier;
      final phoneMatch = user.phoneNumber == trimmedIdentifier || user.phoneNumber == normalizedIdentifier;
      if ((usernameMatch || phoneMatch) && user.password == normalizedPassword) {
        return user;
      }
    }

    return null;
  }
}
