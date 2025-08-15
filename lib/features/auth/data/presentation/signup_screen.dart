import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_app/features/auth/data/presentation/responsive_auth_screen.dart';
import 'package:task_app/features/auth/data/presentation/widgets/auth_form.dart';
import '../../../../core/constants/app_strings.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveAuthScreen(
      formType: AuthFormType.signup,
      title: 'Create Account',
      subtitle: 'Sign up to get started',
      bottomText: AppStrings.alreadyHaveAccount,
      buttonText: AppStrings.login,
      onButtonPressed: () => context.go('/login'),
    );
  }
}