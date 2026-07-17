import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../app/utils/helpers.dart';
import '../../controllers/customer/order_controller.dart';
import '../../data/models/order_model.dart';
import '../../widgets/customer_nav.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/order_status_chip.dart';

class CustomerOrdersView extends StatefulWidget {
  const CustomerOrdersView({super.key});

  @override
  State<CustomerOrdersView> createState() => _CustomerOrdersViewState();
}

class _CustomerOrdersViewState extends State<CustomerOrdersView> {
  final _tab = 0.obs; // 0 = active, 1 = history

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().bindCustomerOrders();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OrderController>();
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: Column(
        children: [
          Obx(
            () => Container(
              margin: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [_tabBtn('Active', 0), _tabBtn('History', 1)],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (ctrl.orders.isEmpty) {
                return const EmptyWidget(
                  title: 'No orders yet',
                  subtitle: 'Your orders will appear here.',
                  icon: Icons.receipt_long,
                );
              }
              final active = ctrl.orders
                  .where(
                    (o) => o.status != 'delivered' && o.status != 'cancelled',
                  )
                  .toList();
              final history = ctrl.orders
                  .where(
                    (o) => o.status == 'delivered' || o.status == 'cancelled',
                  )
                  .toList();
              final list = _tab.value == 0 ? active : history;
              if (list.isEmpty) {
                return const EmptyWidget(
                  title: 'Nothing here',
                  subtitle: 'No orders in this section.',
                  icon: Icons.inbox,
                );
              }
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: list.length,
                itemBuilder: (_, i) => _OrderTile(order: list[i]),
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 1),
    );
  }

  Widget _tabBtn(String label, int index) {
    return Expanded(
      child: Obx(
        () => GestureDetector(
          onTap: () => _tab.value = index,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color:
                  _tab.value == index ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: _tab.value == index
                      ? Colors.white
                      : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderModel order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.customerOrderDetail,
        parameters: {'id': order.id},
      ),
      child: Container(
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
                  child: Text(
                    order.restaurantName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                OrderStatusChip(status: order.status),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              order.items.map((i) => '${i.quantity}x ${i.name}').join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Text(
                  Helpers.formatDate(order.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  Helpers.formatCurrency(order.total),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
