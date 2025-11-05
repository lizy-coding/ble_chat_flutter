import 'package:ble_chat_flutter/src/core/auth/local_auth_service.dart';
import 'package:ble_chat_flutter/src/core/domain/models/local_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { unauthenticated, loading, authenticated, failure }
enum AuthError { agreementRequired, invalidCredentials }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final LocalUser? user;
  final AuthError? error;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    LocalUser? user,
    AuthError? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  static const AuthState unauthenticated = AuthState(status: AuthStatus.unauthenticated);
}

class AuthController extends ChangeNotifier {
  AuthController(this._authService);

  final LocalAuthService _authService;
  AuthState _state = AuthState.unauthenticated;

  AuthState get state => _state;

  Future<void> login({
    required String identifier,
    required String password,
    required bool acceptedAgreement,
  }) async {
    if (!acceptedAgreement) {
      _state = AuthState(status: AuthStatus.failure, error: AuthError.agreementRequired);
      notifyListeners();
      return;
    }

    _state = _state.copyWith(status: AuthStatus.loading, error: null);
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 300));
    final user = _authService.authenticate(identifier: identifier, password: password);
    if (user == null) {
      _state = AuthState(status: AuthStatus.failure, error: AuthError.invalidCredentials);
      notifyListeners();
      return;
    }

    _state = AuthState(status: AuthStatus.authenticated, user: user);
    notifyListeners();
  }

  void logout() {
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}

final authControllerProvider = ChangeNotifierProvider<AuthController>(
  (ref) => AuthController(LocalAuthService()),
);
