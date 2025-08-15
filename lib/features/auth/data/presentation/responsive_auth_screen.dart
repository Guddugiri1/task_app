import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_app/features/auth/data/presentation/widgets/auth_form.dart';
import '../../../../core/constants/app_strings.dart';

// This is the main, reusable, and responsive authentication screen.
class ResponsiveAuthScreen extends StatelessWidget {
  final AuthFormType formType;
  final String title;
  final String subtitle;
  final String bottomText;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const ResponsiveAuthScreen({
    super.key,
    required this.formType,
    required this.title,
    required this.subtitle,
    required this.bottomText,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    // A constant for the breakpoint to switch between layouts.
    const double breakpoint = 700.0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // The decorative blobs are now part of a reusable background.
          const _BlobBackground(),
          SafeArea(
            // LayoutBuilder gives us the constraints of the available space.
            child: LayoutBuilder(
              builder: (context, constraints) {
                // If the screen is WIDE (e.g., tablet, desktop)
                if (constraints.maxWidth >= breakpoint) {
                  return _buildWideLayout(context);
                }
                // If the screen is NARROW (e.g., phone in portrait)
                else {
                  return _buildNarrowLayout(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the single-column layout for narrow screens.
  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 2,
          child: _BrandingSection(),
        ),
        // The form is wrapped in a container with styling.
        _FormContainer(
          child: _FormContent(
            title: title,
            subtitle: subtitle,
            formType: formType,
            bottomText: bottomText,
            buttonText: buttonText,
            onButtonPressed: onButtonPressed,
          ),
        ),
      ],
    );
  }

  /// Builds the side-by-side layout for wide screens.
  Widget _buildWideLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The branding takes up the left side.
            const Expanded(
              child: _BrandingSection(),
            ),
            const SizedBox(width: 64),
            // The form is on the right, constrained to a max width.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: _FormContainer(
                child: _FormContent(
                  title: title,
                  subtitle: subtitle,
                  formType: formType,
                  bottomText: bottomText,
                  buttonText: buttonText,
                  onButtonPressed: onButtonPressed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE UI COMPONENTS ---

/// The top part of the screen with the logo and app name.
class _BrandingSection extends StatelessWidget {
  const _BrandingSection();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logo/logolumo.png',
          height: 100,
          semanticLabel: 'Lumo App Logo',
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.appName,
          style: textTheme.headlineLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// The content inside the form container (title, form, bottom button).
class _FormContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final AuthFormType formType;
  final String bottomText;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const _FormContent({
    required this.title,
    required this.subtitle,
    required this.formType,
    required this.bottomText,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 32),
        AuthForm(formType: formType),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(bottomText),
            TextButton(
              onPressed: onButtonPressed,
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ],
    );
  }
}

/// The container that holds the form, providing consistent styling.
class _FormContainer extends StatelessWidget {
  final Widget child;
  const _FormContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      // Use SingleChildScrollView to prevent overflow on small screens
      child: SingleChildScrollView(child: child),
    );
  }
}

/// The decorative blobs in the background.
class _BlobBackground extends StatelessWidget {
  const _BlobBackground();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: _Blob(
            color: colors.secondary.withOpacity(0.3),
            size: 300,
          ),
        ),
        Positioned(
          bottom: -150,
          left: -150,
          child: _Blob(
            color: colors.primary.withOpacity(0.3),
            size: 400,
          ),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}