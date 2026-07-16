import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../app/theme/app_theme.dart';
import '../app/utils/helpers.dart';
import '../data/models/product_model.dart';
import '../controllers/customer/cart_controller.dart';
import 'network_image.dart';

/// A product row with add/remove quantity stepper, tied to the cart.
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.only(bottom: 12.h),
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
              url: product.imageUrl,
              width: 80.w,
              height: 80.h,
              radius: 12,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  if (product.description != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      product.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        Helpers.formatCurrency(product.effectivePrice),
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: AppTheme.primary),
                      ),
                      if (product.hasDiscount) ...[
                        SizedBox(width: 6.w),
                        Text(
                          Helpers.formatCurrency(product.price),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _Stepper(product: product, cart: cart),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final ProductModel product;
  final CartController cart;
  const _Stepper({required this.product, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final qty =
          cart.items.where((i) => i.product.id == product.id).fold<int>(0, (s, i) => s + i.quantity);
      if (qty == 0) {
        return InkWell(
          onTap: () {
            if (!product.isAvailable) {
              Helpers.showInfo('Currently unavailable');
              return;
            }
            cart.addToCart(product);
          },
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: product.isAvailable ? AppTheme.primary : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 18),
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primary),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => cart.decrement(product.id),
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: const Icon(Icons.remove, size: 16, color: AppTheme.primary),
              ),
            ),
            Text('$qty', style: const TextStyle(fontWeight: FontWeight.w600)),
            InkWell(
              onTap: () => cart.increment(product.id),
              child: Padding(
                padding: EdgeInsets.all(6.w),
                child: const Icon(Icons.add, size: 16, color: AppTheme.primary),
              ),
            ),
          ],
        ),
      );
    });
  }
}
