import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/theme/app_theme.dart';
import '../../app/utils/helpers.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/rider/rider_controller.dart';
import '../../data/models/order_model.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/greeting_header.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/order_status_chip.dart';
import '../../widgets/order_status_timeline.dart';
import '../../widgets/rider_nav.dart';

class RiderHomeView extends StatelessWidget {
  const RiderHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RiderController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Rider')),
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.availableOrders.isEmpty) {
          return const LoadingWidget();
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GreetingHeader(
                name: Get.find<AuthController>().user?.fullName ?? 'Rider',
                roleLabel: 'Delivery partner',
                icon: Icons.delivery_dining,
                color: AppTheme.primary,
              ),
              SizedBox(height: 16.h),
              // Availability switch
              Obx(() => Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: ctrl.isAvailable.value
                            ? [AppTheme.success, const Color(0xFF16A34A)]
                            : [Colors.grey.shade400, Colors.grey.shade500],
                      ),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.delivery_dining,
                            color: Colors.white, size: 34),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ctrl.isAvailable.value
                                    ? 'You are online'
                                    : 'You are offline',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Text('Tap to change availability',
                                  style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                        Switch(
                          value: ctrl.isAvailable.value,
                          activeColor: Colors.white,
                          onChanged: (_) => ctrl.toggleAvailability(),
                        ),
                      ],
                    ),
                  )),
              SizedBox(height: 20.h),
              Text('Available orders',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 10.h),
              if (!ctrl.isAvailable.value)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: const Center(
                    child: Text('Go online to see and accept orders.'),
                  ),
                )
              else if (ctrl.availableOrders.isEmpty)
                const EmptyWidget(
                  title: 'No orders nearby',
                  subtitle: 'New delivery requests will appear here.',
                  icon: Icons.explore,
                )
              else
                ...ctrl.availableOrders.map((o) => _OrderCard(order: o, ctrl: ctrl)),
            ],
          ),
        );
      }),
      bottomNavigationBar: const RiderBottomNav(currentIndex: 0),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final RiderController ctrl;
  const _OrderCard({required this.order, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          Text('To: ${order.customerName}',
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
              ElevatedButton(
                onPressed: () => ctrl.acceptOrder(order),
                child: const Text('Accept'),
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
