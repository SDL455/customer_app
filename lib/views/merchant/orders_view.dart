import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/theme/app_theme.dart';
import '../../app/utils/helpers.dart';
import '../../controllers/merchant/merchant_controller.dart';
import '../../data/models/order_model.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/merchant_nav.dart';
import '../../widgets/order_status_chip.dart';
import '../../widgets/order_status_timeline.dart';

class MerchantOrdersView extends StatelessWidget {
  const MerchantOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MerchantController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.orders.isEmpty) {
          return const LoadingWidget();
        }
        if (ctrl.orders.isEmpty) {
          return const EmptyWidget(
            title: 'No orders yet',
            subtitle: 'New orders from customers will appear here.',
            icon: Icons.receipt_long,
          );
        }
        final sorted = [...ctrl.orders]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: sorted.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (_, i) => _OrderCard(order: sorted[i], ctrl: ctrl),
        );
      }),
      bottomNavigationBar: const MerchantBottomNav(currentIndex: 1),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final MerchantController ctrl;
  const _OrderCard({required this.order, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              OrderStatusChip(status: order.status),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            order.items.map((i) => '${i.quantity}x ${i.name}').join(', '),
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  order.deliveryAddress ?? 'No address',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(Helpers.formatCurrency(order.total),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              if (order.status == 'pending') ...[
                OutlinedButton(
                  onPressed: () => ctrl.rejectOrder(order),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.error),
                    foregroundColor: AppTheme.error,
                  ),
                  child: const Text('Reject'),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () => ctrl.acceptOrder(order),
                  child: const Text('Accept'),
                ),
              ],
              if (order.status == 'accepted')
                ElevatedButton(
                  onPressed: () => ctrl.startPreparing(order),
                  child: const Text('Start preparing'),
                ),
              if (order.status == 'preparing')
                OutlinedButton(
                  onPressed: () => ctrl.markReady(order),
                  child: const Text('Mark ready'),
                ),
              if (order.status == 'ready')
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: const Text('Waiting for rider',
                      style: TextStyle(color: AppTheme.info, fontSize: 12)),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          OrderStatusTimeline(status: order.status),
        ],
      ),
    );
  }
}
