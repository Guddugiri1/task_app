import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// A premium, responsive, custom-styled bottom navigation bar with advanced animations,
/// a dynamic glow effect, and an elevated central FloatingActionButton.
class BottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavBar({super.key, required this.navigationShell});

  void _onTap(int index) {
    HapticFeedback.lightImpact();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.20),
                _NavBarItem(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => _onTap(2),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            child: _CentralActionButton(
              isSelected: navigationShell.currentIndex == 1,
              onTap: () => _onTap(1),
            ),
          ),
        ],
      ),
    );
  }
}

// --- REUSABLE UI WIDGETS ---

class _CentralActionButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  const _CentralActionButton({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          scale: isSelected ? 1.1 : 1.0,
          child: FloatingActionButton(
            onPressed: onTap,
            elevation: isSelected ? 8.0 : 4.0,
            backgroundColor: Theme.of(context).primaryColor,
            shape: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/logo/logolumo.png',
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'LUMO AI',
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}

/// A single tappable item for the bar, now fully overflow-proof.
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey[600];
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // --- THIS IS THE OVERFLOW FIX ---
        // By using Transform.translate, we can create the "pop" animation
        // without changing the layout, which guarantees no overflows.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, isSelected ? -10.0 : 0.0, 0),
          transformAlignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  _GlowEffect(isSelected: isSelected),
                  Icon(
                    isSelected ? selectedIcon : icon,
                    color: color,
                    size: 26,
                  ),
                ],
              ),
              // FIX: Slightly reduced the space to give more breathing room.
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A reusable widget that creates the soft glow effect.
class _GlowEffect extends StatelessWidget {
  final bool isSelected;
  const _GlowEffect({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isSelected ? 1.0 : 0.0,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.4),
              blurRadius: 15.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
      ),
    );
  }
}