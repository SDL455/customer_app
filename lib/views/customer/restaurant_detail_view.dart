import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/theme/app_theme.dart';
import '../../app/utils/helpers.dart';
import '../../controllers/customer/cart_controller.dart';
import '../../data/models/restaurant_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/network_image.dart';
import '../../widgets/product_card.dart';

class RestaurantDetailView extends StatelessWidget {
  RestaurantDetailView({super.key});

  final String id = Get.parameters['id'] ?? '';

  @override
  Widget build(BuildContext context) {
    final fs = Get.find<FirestoreService>();
    final cart = Get.find<CartController>();
    return Scaffold(
      body: StreamBuilder<RestaurantModel?>(
        stream: fs.restaurantStream(id),
        builder: (ctx, snap) {
          if (!snap.hasData) return const LoadingWidget();
          final restaurant = snap.data!;
          return StreamBuilder(
            stream: fs.productsStream(id),
            builder: (ctx2, pSnap) {
              final products = pSnap.data ?? [];
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 180.h,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: NetImage(
                        url: restaurant.coverUrl ?? restaurant.imageUrl,
                        height: 180.h,
                        radius: 0,
                      ),
                    ),
                    leading: Container(
                      margin: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(restaurant.name,
                                    style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star,
                                        size: 14, color: Color(0xFFFFC107)),
                                    SizedBox(width: 4.w),
                                    Text(restaurant.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (restaurant.description != null) ...[
                            SizedBox(height: 6.h),
                            Text(restaurant.description!,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary)),
                          ],
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              _meta(Icons.delivery_dining,
                                  Helpers.formatCurrency(restaurant.deliveryFee)),
                              SizedBox(width: 16.w),
                              _meta(Icons.timer_outlined,
                                  '${restaurant.deliveryTimeMin} min'),
                              SizedBox(width: 16.w),
                              _meta(Icons.shopping_bag_outlined,
                                  'Min ${Helpers.formatCurrency(restaurant.minOrder)}'),
                            ],
                          ),
                          if (!restaurant.isOpen) ...[
                            SizedBox(height: 16.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: const Text('This store is currently closed.',
                                  style: TextStyle(color: Colors.orange)),
                            ),
                          ],
                          SizedBox(height: 18.h),
                          Text('Menu',
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 12.h),
                        ],
                      ),
                    ),
                  ),
                  if (pSnap.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()))
                  else if (products.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: const Center(
                            child: Text('No items on the menu yet.')),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: ProductCard(
                            product: products[i],
                            onTap: () => cart.addToCart(products[i],
                                fromRestaurant: restaurant),
                          ),
                        ),
                        childCount: products.length,
                      ),
                    ),
                  SliverToBoxAdapter(child: SizedBox(height: 90.h)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppTheme.primary),
        SizedBox(width: 4.w),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
