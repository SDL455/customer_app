import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/theme/app_theme.dart';
import '../../app/utils/helpers.dart';
import '../../controllers/rider/rider_controller.dart';
import '../../data/models/order_model.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/order_status_chip.dart';
import '../../widgets/order_status_timeline.dart';
import '../../widgets/rider_nav.dart';

class RiderOrdersView extends StatelessWidget {
  const RiderOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RiderController>();
    return Scaffold(
      appBar: AppBar(title: const Text('My deliveries')),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.myOrders.isEmpty) {
          return const LoadingWidget();
        }
        if (ctrl.myOrders.isEmpty) {
          return const EmptyWidget(
            title: 'No active deliveries',
            subtitle: 'Accepted orders will show up here.',
            icon: Icons.delivery_dining,
          );
        }
        final sorted = [...ctrl.myOrders]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: sorted.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (_, i) => _DeliveryCard(order: sorted[i], ctrl: ctrl),
        );
      }),
      bottomNavigationBar: const RiderBottomNav(currentIndex: 1),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final OrderModel order;
  final RiderController ctrl;
  const _DeliveryCard({required this.order, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(order.restaurantName, style: const TextStyle(fontWeight: FontWeight.w600))),
              OrderStatusChip(status: order.status),
            ],
          ),
          SizedBox(height: 6.h),
          Text('Customer: ${order.customerName}',
              style: const TextStyle(color: AppTheme.textSecondary)),
          SizedBox(height: 4.h),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(order.deliveryAddress ?? 'No address',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(Helpers.formatCurrency(order.total),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              if (order.status == 'accepted' || order.status == 'preparing')
                ElevatedButton(
                  onPressed: () => ctrl.pickUp(order),
                  child: const Text('Pick up'),
                ),
              if (order.status == 'picked_up' || order.status == 'ready')
                ElevatedButton(
                  onPressed: () => ctrl.completeDelivery(order),
                  child: const Text('Deliver'),
                ),
              if (order.status == 'delivered')
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: const Text('Completed',
                      style: TextStyle(color: AppTheme.success, fontSize: 12)),
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
