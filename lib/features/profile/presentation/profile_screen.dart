import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_info_provider.dart';
import 'package:task_app/core/widgets/confirmation_dialog.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/data/providers/auth_providers.dart';

/// A professionally designed, responsive profile screen that adapts its layout
/// from a single column on narrow screens to a two-column layout on wide screens.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showStyledConfirmationDialog(
      context: context,
      title: 'Confirm Logout',
      content: 'Are you sure you want to log out?',
      confirmText: 'Logout',
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    const double breakpoint = 800.0; // The width at which the layout changes

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: userProfileAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          // LayoutBuilder provides the screen constraints to decide which layout to use.
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > breakpoint) {
                return _buildWideLayout(user, context, ref);
              } else {
                return _buildNarrowLayout(user, context, ref);
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('An error occurred: $err')),
      ),
    );
  }

  /// Builds the single-column layout for phones and narrow screens.
  Widget _buildNarrowLayout(UserModel user, BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _ProfileInfoCard(user: user),
          const SizedBox(height: 24),
          _DetailsSection(
            user: user,
            onSignOut: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
    );
  }

  /// Builds the two-column layout for tablets, web, and wide screens.
  Widget _buildWideLayout(UserModel user, BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Row(
        children: [
          // The Identity Card is fixed on the left.
          SizedBox(
            width: 350,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _ProfileInfoCard(user: user),
            ),
          ),
          const VerticalDivider(width: 1),
          // The Details Section is scrollable on the right.
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                _DetailsSection(
                  user: user,
                  onSignOut: () => _confirmSignOut(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- NEW, REUSABLE UI COMPONENTS ---

/// The main "Identity Card" for the user.
class _ProfileInfoCard extends StatelessWidget {
  final UserModel user;
  const _ProfileInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 8,
      shadowColor: theme.primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [theme.primaryColor, Colors.indigo.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset('assets/logo/logolumo.png'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.username,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget containing all the secondary details and actions.
class _DetailsSection extends ConsumerWidget {
  final UserModel user;
  final VoidCallback onSignOut;
  const _DetailsSection({required this.user, required this.onSignOut});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'USER DETAILS'),
        _InfoRow(
          icon: Icons.email_outlined,
          title: 'Email Address',
          subtitle: user.email,
        ),
        const Divider(),
        _InfoRow(
          icon: Icons.phone_iphone_rounded,
          title: 'Mobile Number',
          subtitle: user.mobileNumber ?? 'Not provided',
        ),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'ABOUT & SUPPORT'),
        const _InfoRow(
          icon: Icons.support_agent_rounded,
          title: 'Contact Support',
          subtitle: 'Get help with your account',
        ),
        const Divider(),
        _InfoRow(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'Read our terms of service',
        ),
        const SizedBox(height: 24),
        const _SectionHeader(title: 'APP INFO'),
        packageInfo.when(
          data: (info) => _InfoRow(
            icon: Icons.terminal_rounded,
            title: 'App Version',
            subtitle: '${info.version} (Lumo ${info.buildNumber})',
          ),
          loading: () => const _InfoRow(icon: Icons.hourglass_empty, title: 'App Version', subtitle: 'Loading...'),
          error: (e, s) => const _InfoRow(icon: Icons.error_outline, title: 'App Version', subtitle: 'Could not load'),
        ),
        const SizedBox(height: 32),
        Center(
          child: _LogoutButton(onPressed: onSignOut),
        ),
      ],
    );
  }
}

/// A custom, styled header for different sections of the list.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// The new, bespoke row widget for displaying information.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A styled logout button.
class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
      label: Text(
        'Sign Out',
        style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.error.withOpacity(0.3)),
        ),
      ),
    );
  }
}