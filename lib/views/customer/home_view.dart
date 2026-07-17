import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/customer/home_controller.dart';
import '../../widgets/customer_nav.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/restaurant_card.dart';

class CustomerHomeView extends StatelessWidget {
  const CustomerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodPanda'),
      ),
      body: Column(
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(18.w),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hungry?',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4.h),
                      const Text('Order from top restaurants near you',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const Icon(Icons.delivery_dining,
                    color: Colors.white, size: 46),
              ],
            ),
          ),
          // Live search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                onChanged: ctrl.onSearch,
                decoration: InputDecoration(
                  hintText: 'Search restaurants or food...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.primary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value && ctrl.restaurants.isEmpty) {
                return const LoadingWidget();
              }
              if (ctrl.filtered.isEmpty) {
                return const EmptyWidget(
                  title: 'No restaurants found',
                  subtitle: 'Try a different search or category.',
                  icon: Icons.search_off,
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ctrl.load(),
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    // Category chips
                    if (ctrl.categories.isNotEmpty) ...[
                      SizedBox(
                        height: 44.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: ctrl.categories.length + 1,
                          separatorBuilder: (_, __) => SizedBox(width: 8.w),
                          itemBuilder: (_, i) {
                            if (i == 0) {
                              final active =
                                  ctrl.selectedCategory.value.isEmpty;
                              return _chip(
                                  'All', active, () => ctrl.selectCategory(''));
                            }
                            final c = ctrl.categories[i - 1];
                            final active = ctrl.selectedCategory.value == c.id;
                            return _chip(
                                c.emoji != null
                                    ? '${c.emoji} ${c.name}'
                                    : c.name,
                                active,
                                () => ctrl.selectCategory(c.id));
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                    Text('Popular restaurants',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 250.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: ctrl.filtered.length,
                        separatorBuilder: (_, __) => const SizedBox.shrink(),
                        itemBuilder: (_, i) => FadeInRight(
                          delay: Duration(milliseconds: i * 60),
                          child: RestaurantCard(
                            restaurant: ctrl.filtered[i],
                            onTap: () => Get.toNamed(
                              AppRoutes.restaurantDetail,
                              parameters: {'id': ctrl.filtered[i].id},
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text('All restaurants',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 12.h),
                    ...ctrl.filtered.map((r) => RestaurantCard(
                          restaurant: r,
                          onTap: () => Get.toNamed(AppRoutes.restaurantDetail,
                              parameters: {'id': r.id}),
                        ).marginOnly(bottom: 12.h)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: const CartFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 0),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border:
              Border.all(color: active ? AppTheme.primary : AppTheme.divider),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? Colors.white : AppTheme.textSecondary,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  void _showSearch(BuildContext context, HomeController ctrl) {
    final c = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
            left: 16.w,
            right: 16.w,
            top: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c,
              autofocus: true,
              onChanged: ctrl.onSearch,
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
