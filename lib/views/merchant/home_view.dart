import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../app/utils/helpers.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/merchant/merchant_controller.dart';
import '../../widgets/greeting_header.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/merchant_nav.dart';

class MerchantHomeView extends StatelessWidget {
  const MerchantHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MerchantController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant'),
        actions: [
          Obx(() => IconButton(
                icon: Icon(ctrl.restaurant.value?.isOpen ?? false
                    ? Icons.store
                    : Icons.storefront_outlined),
                tooltip: 'Toggle store open/closed',
                onPressed: ctrl.toggleStoreOpen,
              )),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.restaurant.value == null) {
          return const LoadingWidget();
        }
        if (ctrl.restaurant.value == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No restaurant is linked to this account yet. '
                'An admin must create your store and assign it to you.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final r = ctrl.restaurant.value!;
        final pending =
            ctrl.orders.where((o) => o.status == 'pending').length;
        final active = ctrl.orders
            .where((o) =>
                o.status != 'pending' &&
                o.status != 'delivered' &&
                o.status != 'cancelled')
            .length;
        final revenue = ctrl.orders
            .where((o) => o.status == 'delivered')
            .fold(0.0, (s, o) => s + o.total);
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreetingHeader(
                name: Get.find<AuthController>().user?.fullName ?? 'Partner',
                roleLabel: 'Merchant partner',
                icon: Icons.storefront,
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    Text(
                      r.isOpen ? 'Open • Accepting orders' : 'Closed',
                      style: TextStyle(
                        color: r.isOpen ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  _stat(pending.toString(), 'New orders',
                      Icons.notifications_active, AppTheme.warning),
                  SizedBox(width: 12.w),
                  _stat(active.toString(), 'In progress',
                      Icons.restaurant, AppTheme.info),
                ],
              ),
              SizedBox(height: 12.h),
              _stat(Helpers.formatCurrency(revenue), 'Total revenue',
                  Icons.attach_money, AppTheme.success),
              SizedBox(height: 20.h),
              Text('Menu',
                  style: TextStyle(
                      fontSize: 18.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Get.toNamed(AppRoutes.merchantAddProduct),
                      icon: const Icon(Icons.add),
                      label: const Text('Add product'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (ctrl.products.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: const Center(
                      child: Text('No products yet. Add your first item!')),
                )
              else
                ...ctrl.products.map((p) => Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 4.h),
                                Text(
                                  Helpers.formatCurrency(p.effectivePrice) +
                                      (p.categoryName != null
                                          ? ' • ${p.categoryName}'
                                          : ''),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => Get.toNamed(
                                AppRoutes.merchantEditProduct,
                                parameters: {'id': p.id}),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18,
                                color: AppTheme.error),
                            onPressed: () => ctrl.deleteProduct(p.id),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        );
      }),
      bottomNavigationBar: const MerchantBottomNav(currentIndex: 0),
    );
  }

  Widget _stat(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
