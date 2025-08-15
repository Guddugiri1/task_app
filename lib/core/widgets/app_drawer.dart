import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_app/core/providers/app_info_provider.dart';
import 'package:task_app/core/widgets/confirmation_dialog.dart';
import 'package:task_app/features/auth/data/models/user_model.dart';
import 'package:task_app/features/auth/data/providers/auth_providers.dart';

/// A comprehensive and beautifully styled drawer for all app actions and navigation.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  /// Handles the logout process, including the confirmation dialog.
  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    final authRepository = ref.read(authRepositoryProvider);
    if (!context.mounted) return;

    final confirmed = await showStyledConfirmationDialog(
      context: context,
      title: 'Confirm Logout',
      content: 'Are you sure you want to log out?',
      confirmText: 'Logout',
    );
    if (confirmed == true) {
      await authRepository.signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;

    return Drawer(
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeaderContent(user: userProfile),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- NEW "NAVIGATION" SECTION ---
                  const _SectionTitle(title: 'NAVIGATION'),
                  _DrawerTile(
                    title: 'Dashboard',
                    icon: Icons.dashboard_rounded,
                    onTap: () {
                      Navigator.of(context).pop();
                      // Use .go() to switch the main branch of the ShellRoute
                      context.go('/dashboard');
                    },
                  ),
                  _DrawerTile(
                    title: 'Task List',
                    icon: Icons.list_alt_rounded,
                    onTap: () {
                      Navigator.of(context).pop();
                      // Use .push() because TaskList is a separate page
                      context.push('/tasks');
                    },
                  ),

                  const SizedBox(height: 16), // Spacer between sections

                  // --- "ACTIONS" SECTION ---
                  const _SectionTitle(title: 'ACTIONS'),
                  _DrawerTile(
                    title: 'Add New Task',
                    icon: Icons.add_circle_outline_rounded,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/add-task');
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(indent: 16, endIndent: 16),
                  const _SectionTitle(title: 'ACCOUNT'),
                  _DrawerTile(
                    title: 'Logout',
                    icon: Icons.logout_rounded,
                    color: Theme.of(context).colorScheme.error,
                    onTap: () {
                      Navigator.of(context).pop();
                      _confirmSignOut(context, ref);
                    },
                  ),
                ],
              ),
            ),
            const _DrawerFooter(),
          ],
        ),
      ),
    );
  }
}

// --- DRAWER UI HELPER WIDGETS ---

class _DrawerHeaderContent extends StatelessWidget {
  final UserModel? user;
  const _DrawerHeaderContent({this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20 + topPadding, 20, 24),
      decoration: BoxDecoration(color: theme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/logo/logolumo.png'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.username ?? 'Welcome!',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'Loading...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurfaceVariant;

    return ListTile(
      leading: Icon(icon, color: effectiveColor),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(color: effectiveColor),
      ),
      onTap: onTap,
      splashColor: effectiveColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _DrawerFooter extends ConsumerWidget {
  const _DrawerFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: packageInfo.when(
          data: (info) => Text(
            'Lumo v${info.version}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
          loading: () => const SizedBox.shrink(),
          error: (err, stack) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}