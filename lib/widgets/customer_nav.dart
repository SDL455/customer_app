import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;

import '../app/routes/app_routes.dart';
import '../app/theme/app_theme.dart';
import '../controllers/customer/cart_controller.dart';

/// Shared bottom navigation for the customer experience.
class CustomerBottomNav extends StatelessWidget {
  final int currentIndex;
  const CustomerBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item(Icons.home_rounded, 'Home', AppRoutes.customerHome),
      _Item(Icons.receipt_long_rounded, 'Orders', AppRoutes.customerOrders),
      _Item(Icons.person_rounded, 'Profile', AppRoutes.customerProfile),
    ];
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.textSecondary,
      showUnselectedLabels: true,
      onTap: (i) {
        if (i == currentIndex) return;
        Get.offNamedUntil(items[i].route, (r) => false);
      },
      items: items
          .map((it) => BottomNavigationBarItem(
                icon: Icon(it.icon),
                label: it.label,
              ))
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

/// Floating cart bar that shows item count + total and opens the cart.
class CartFAB extends StatelessWidget {
  const CartFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return Obx(() {
      if (cart.items.isEmpty) return const SizedBox.shrink();
      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.cart),
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: badges.Badge(
            badgeContent: Text('${cart.count}',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
            badgeStyle:
                const badges.BadgeStyle(badgeColor: Colors.white),
            position: badges.BadgePosition.topEnd(top: -10, end: -12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                SizedBox(width: 8.w),
                Text('View cart',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                SizedBox(width: 10.w),
                Text('\$${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
    });
  }
}
