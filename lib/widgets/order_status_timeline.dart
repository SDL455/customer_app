import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app/theme/app_theme.dart';

/// Horizontal order-status stepper shared by customer / merchant / rider.
/// Highlights every step up to (and including) the current [status].
class OrderStatusTimeline extends StatelessWidget {
  final String status;
  final double? width;

  const OrderStatusTimeline({super.key, required this.status, this.width});

  static const List<_Step> _steps = [
    _Step('pending', 'Ordered', Icons.receipt_long),
    _Step('preparing', 'Cooking', Icons.restaurant),
    _Step('accepted', 'Assigned', Icons.delivery_dining),
    _Step('ready', 'Ready', Icons.inventory_2),
    _Step('picked_up', 'On way', Icons.electric_bike),
    _Step('delivered', 'Done', Icons.verified),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexWhere((s) => s.key == status);
    final active = currentIndex < 0 ? 0 : currentIndex;
    final isCancelled = status == 'cancelled';

    if (isCancelled) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, color: AppTheme.error, size: 18),
            SizedBox(width: 8),
            Text('Order cancelled',
                style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width ?? (_steps.length * 64.w),
        child: Row(
          children: List.generate(_steps.length, (i) {
            final step = _steps[i];
            final done = i <= active;
            final isLast = i == _steps.length - 1;
            return Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26.w,
                        height: 26.w,
                        decoration: BoxDecoration(
                          color: done ? AppTheme.primary : AppTheme.divider,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(step.icon,
                            size: 14,
                            color: done ? Colors.white : AppTheme.textSecondary),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            height: 3.h,
                            color: i < active
                                ? AppTheme.primary
                                : AppTheme.divider,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(step.label,
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: done
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontWeight: done ? FontWeight.w600 : FontWeight.normal)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Step {
  final String key;
  final String label;
  final IconData icon;
  const _Step(this.key, this.label, this.icon);
}
