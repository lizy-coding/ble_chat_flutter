import 'package:ble_chat_flutter/src/core/auth/auth_controller.dart';
import 'package:ble_chat_flutter/src/core/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreementAccepted = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider).login(
          identifier: _identifierController.text,
          password: _passwordController.text,
          acceptedAgreement: _agreementAccepted,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);
    final authState = authController.state;
    final l10n = context.l10n;

    String? errorText;
    if (authState.status == AuthStatus.failure && authState.error != null) {
      switch (authState.error!) {
        case AuthError.agreementRequired:
          errorText = l10n.loginAgreementRequired;
          break;
        case AuthError.invalidCredentials:
          errorText = l10n.loginInvalidCredentials;
          break;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 600 ? constraints.maxWidth * 0.2 : 24.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 48, horizontalPadding, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.loginTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.loginSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _identifierController,
                      decoration: InputDecoration(
                        labelText: l10n.loginIdentifierLabel,
                        hintText: l10n.loginIdentifierHint,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.loginIdentifierRequired;
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: l10n.loginPasswordLabel,
                        hintText: l10n.loginPasswordHint,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.loginPasswordRequired;
                        }
                        if (value.trim().length < 6) {
                          return l10n.loginPasswordLengthRule;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _agreementAccepted,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(l10n.loginAgreementLabel),
                      onChanged: (value) {
                        setState(() {
                          _agreementAccepted = value ?? false;
                        });
                      },
                    ),
                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          errorText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _agreementAccepted ? _submit : null,
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.loginButtonLabel),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
