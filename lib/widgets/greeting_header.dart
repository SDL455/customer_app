import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app/theme/app_theme.dart';

/// A consistent greeting header (avatar + name + role) used at the top of the
/// merchant and rider dashboards.
class GreetingHeader extends StatelessWidget {
  final String name;
  final String roleLabel;
  final IconData icon;
  final Color color;

  const GreetingHeader({
    super.key,
    required this.name,
    required this.roleLabel,
    required this.icon,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24.r,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hi, ${name.split(' ').first}',
                  style: TextStyle(
                      fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),
              Text(roleLabel,
                  style: const TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
