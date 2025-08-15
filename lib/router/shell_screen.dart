import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_app/core/widgets/app_drawer.dart';
import 'package:task_app/core/widgets/bottom_nav_bar.dart';


class ShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScreen({super.key, required this.navigationShell});

  String _getTitle(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'LUMO AI';
      case 2:
        return 'Profile';
      default:
        return 'Lumo';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(navigationShell.currentIndex)),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Open Menu',
            );
          },
        ),
        actions: const [
          SizedBox(width: 56), // Placeholder to balance the leading icon
        ],
      ),
      // --- THIS IS THE SIMPLIFIED IMPLEMENTATION ---
      // The drawer is now self-contained and requires no callbacks.
      drawer: const AppDrawer(),
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(navigationShell: navigationShell),
      floatingActionButton: null, // No FAB as per your request
    );
  }
}