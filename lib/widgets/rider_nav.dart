import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/routes/app_routes.dart';
import '../app/theme/app_theme.dart';

/// Shared bottom navigation for the rider experience.
class RiderBottomNav extends StatelessWidget {
  final int currentIndex;
  const RiderBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item(Icons.explore_rounded, 'Available', AppRoutes.riderHome),
      _Item(Icons.delivery_dining_rounded, 'My deliveries',
          AppRoutes.riderOrders),
      _Item(Icons.person_rounded, 'Profile', AppRoutes.riderProfile),
    ];
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.textSecondary,
      type: BottomNavigationBarType.fixed,
      onTap: (i) {
        if (i == currentIndex) return;
        Get.offNamedUntil(items[i].route, (r) => false);
      },
      items: items
          .map((it) =>
              BottomNavigationBarItem(icon: Icon(it.icon), label: it.label))
          .toList(),
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final String route;
  _Item(this.icon, this.label, this.route);
}
