import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_app/features/auth/data/presentation/responsive_auth_screen.dart';
import 'package:task_app/features/auth/data/presentation/widgets/auth_form.dart';
import '../../../../core/constants/app_strings.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveAuthScreen(
      formType: AuthFormType.login,
      title: 'Welcome Back!',
      subtitle: 'Login to your account to continue',
      bottomText: AppStrings.dontHaveAccount,
      buttonText: AppStrings.signup,
      onButtonPressed: () => context.go('/signup'),
    );
  }
}