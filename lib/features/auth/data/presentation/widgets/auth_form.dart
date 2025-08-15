import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/validators.dart';
import '../../providers/auth_providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/snackbar_utils.dart';
import '../../../../../core/utils/validators.dart';
import '../../providers/auth_providers.dart';

enum AuthFormType { login, signup }

class AuthForm extends ConsumerStatefulWidget {
  final AuthFormType formType;
  const AuthForm({super.key, required this.formType});

  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _mobileController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authRepo = ref.read(authRepositoryProvider);
        if (widget.formType == AuthFormType.login) {
          await authRepo.signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        } else {
          await authRepo.signUpWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            username: _usernameController.text.trim(),
            mobileNumber: _mobileController.text.trim(),
          );
        }
      } catch (e) {
        if (mounted) {
          showStyledSnackBar(context: context, content: e.toString());
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignup = widget.formType == AuthFormType.signup;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isSignup)
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a username' : null,
              textInputAction: TextInputAction.next,
            ),
          if (isSignup) const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: AppStrings.email),
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: AppStrings.password),
            validator: Validators.password,
            obscureText: true,
            textInputAction: isSignup ? TextInputAction.next : TextInputAction.done,
            onFieldSubmitted: isSignup ? null : (_) => _submit(),
          ),
          const SizedBox(height: 16),

          if (isSignup)
            TextFormField(
              controller: _mobileController,
              decoration: const InputDecoration(labelText: 'Mobile Number (Optional)'),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),

          const SizedBox(height: 24),

          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(isSignup ? AppStrings.signup : AppStrings.login),
          ),
        ],
      ),
    );
  }
}