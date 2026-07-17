import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../../app/theme/app_theme.dart';
import '../../app/utils/helpers.dart';
import '../../controllers/customer/order_controller.dart';
import '../../services/firestore_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/order_status_chip.dart';
import '../../widgets/order_status_timeline.dart';

class CustomerOrderDetailView extends StatelessWidget {
  CustomerOrderDetailView({super.key});

  final String id = Get.parameters['id'] ?? '';
  final _rating = 5.0.obs;
  final _comment = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final fs = Get.find<FirestoreService>();
    final ctrl = Get.find<OrderController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Order details')),
      body: StreamBuilder(
        stream: fs.orderStream(id),
        builder: (ctx, snap) {
          if (!snap.hasData) return const LoadingWidget();
          final order = snap.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.restaurantName,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            SizedBox(height: 4.h),
                            Text(Helpers.formatDate(order.createdAt),
                                style: const TextStyle(
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      OrderStatusChip(status: order.status),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                OrderStatusTimeline(status: order.status),
                SizedBox(height: 16.h),
                Text('Items',
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 10.h),
                ...order.items.map((i) => Container(
                      padding: EdgeInsets.all(12.w),
                      margin: EdgeInsets.only(bottom: 8.h),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                                '${i.quantity}x ${i.name}${i.note != null ? ' (${i.note})' : ''}'),
                          ),
                          Text(Helpers.formatCurrency(i.total),
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Column(
                    children: [
                      _row('Subtotal', Helpers.formatCurrency(order.subtotal)),
                      SizedBox(height: 6.h),
                      _row('Delivery', Helpers.formatCurrency(order.deliveryFee)),
                      const Divider(height: 16),
                      _row('Total', Helpers.formatCurrency(order.total),
                          bold: true, color: AppTheme.primary),
                    ],
                  ),
                ),
                if (order.deliveryAddress != null) ...[
                  SizedBox(height: 16.h),
                  Text('Deliver to',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppTheme.primary),
                        SizedBox(width: 8.w),
                        Expanded(child: Text(order.deliveryAddress!)),
                      ],
                    ),
                  ),
                ],
                if (order.status == 'delivered') ...[
                  SizedBox(height: 24.h),
                  Text('Rate your experience',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 10.h),
                  Obx(() => Center(
                        child: RatingBar.builder(
                          initialRating: _rating.value,
                          minRating: 1,
                          allowHalfRating: false,
                          itemBuilder: (_, __) => const Icon(
                            Icons.star,
                            color: Color(0xFFFFC107),
                          ),
                          onRatingUpdate: (v) => _rating.value = v,
                        ),
                      )),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: _comment,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add a comment (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => ctrl.addReview(
                        order: order,
                        rating: _rating.value,
                        comment: _comment.text.trim(),
                      ),
                      child: const Text('Submit review'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value,
      {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: bold ? 16.sp : 14.sp,
                color: color ?? AppTheme.textPrimary)),
      ],
    );
  }
}
