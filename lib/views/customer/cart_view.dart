import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../app/utils/helpers.dart';
import '../../controllers/customer/cart_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/network_image.dart';

class CartView extends StatelessWidget {
  CartView({super.key});

  final _notes = <String, TextEditingController>{};

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (cart.items.isEmpty) {
          return const EmptyWidget(
            title: 'Your cart is empty',
            subtitle: 'Add items from a restaurant to get started.',
            icon: Icons.shopping_cart_outlined,
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (_, i) {
                  final item = cart.items[i];
                  _notes.putIfAbsent(
                      item.product.id, () => TextEditingController());
                  return Container(
                    padding: EdgeInsets.all(12.w),
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
                        NetImage(
                          url: item.product.imageUrl,
                          width: 64.w,
                          height: 64.h,
                          radius: 12,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 4.h),
                              Text(
                                  Helpers.formatCurrency(
                                      item.product.effectivePrice),
                                  style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 6.h),
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: AppTheme.primary),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () =>
                                          cart.decrement(item.product.id),
                                      child: Padding(
                                        padding: EdgeInsets.all(6.w),
                                        child: const Icon(Icons.remove,
                                            size: 16, color: AppTheme.primary),
                                      ),
                                    ),
                                    Text('${item.quantity}'),
                                    InkWell(
                                      onTap: () =>
                                          cart.increment(item.product.id),
                                      child: Padding(
                                        padding: EdgeInsets.all(6.w),
                                        child: const Icon(Icons.add,
                                            size: 16, color: AppTheme.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(Helpers.formatCurrency(item.total),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),
            _summary(cart),
          ],
        );
      }),
    );
  }

  Widget _summary(CartController cart) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _row('Subtotal', Helpers.formatCurrency(cart.subtotal)),
          SizedBox(height: 6.h),
          _row('Delivery fee', Helpers.formatCurrency(cart.deliveryFee)),
          const Divider(height: 16),
          _row('Total', Helpers.formatCurrency(cart.total),
              bold: true, color: AppTheme.primary),
          SizedBox(height: 12.h),
          CustomButton(
            label: 'Checkout',
            onPressed: () => Get.toNamed(AppRoutes.checkout),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: bold ? 16.sp : 14.sp,
                fontWeight: FontWeight.w700,
                color: color ?? AppTheme.textPrimary)),
      ],
    );
  }
}
