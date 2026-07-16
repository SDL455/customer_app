import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/theme/app_theme.dart';
import '../../app/utils/helpers.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/rider/rider_controller.dart';
import '../../widgets/rider_nav.dart';

class RiderProfileView extends StatelessWidget {
  const RiderProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final ctrl = Get.find<RiderController>();
    final user = auth.user!;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Colors.white,
                    child: Text(Helpers.initials(user.fullName),
                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Text('Rider • ${user.vehicleType ?? 'bike'}',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Obx(() => Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14.r)),
                  child: Row(
                    children: [
                      const Icon(Icons.delivery_dining, color: AppTheme.primary),
                      SizedBox(width: 10.w),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Availability', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('Accept delivery requests', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      Switch(
                        value: ctrl.isAvailable.value,
                        activeColor: AppTheme.primary,
                        onChanged: (_) => ctrl.toggleAvailability(),
                      ),
                    ],
                  ),
                )),
            SizedBox(height: 10.h),
            _tile(Icons.star, 'My rating', '${user.riderRating.toStringAsFixed(1)} / 5.0', () {}),
            _tile(Icons.phone, 'Phone', user.phone, () {}),
            _tile(Icons.help_outline, 'Help & support', 'Contact admin', () {
              Helpers.showInfo('Contact your admin for assistance.');
            }),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: auth.logout,
                icon: const Icon(Icons.logout, color: AppTheme.error),
                label: const Text('Sign out', style: TextStyle(color: AppTheme.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.error),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const RiderBottomNav(currentIndex: 2),
    );
  }

  Widget _tile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
