import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/validators.dart';
import '../controllers/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isLogin = authController.isLoginMode;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isLogin ? 'Welcome back' : 'Create an account',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Student email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: Validators.email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                        ),
                        const SizedBox(height: 16),
                        _PasswordField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: _obscurePassword,
                          onToggleVisibility: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        if (!isLogin) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmController,
                            decoration: const InputDecoration(
                              labelText: 'Confirm password',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return Validators.password(value);
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed:
                              authController.isLoading ? null : () => _submit(),
                          icon: authController.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(isLogin ? Icons.login : Icons.person_add),
                          label: Text(isLogin ? 'Login' : 'Register'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: authController.isLoading
                              ? null
                              : authController.toggleMode,
                          child: Text(
                            isLogin
                                ? "Need an account? Register"
                                : "Already have an account? Login",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final controller = context.read<AuthController>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await controller.submit(
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: controller.isLoginMode ? null : _confirmController.text,
      );
    } catch (error) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error.toString().replaceFirst('StateError: ', ''),
            ),
          ),
        );
    }
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggleVisibility,
        ),
      ),
      obscureText: obscureText,
      validator: Validators.password,
      autofillHints: const [AutofillHints.password],
    );
  }
}

