import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../app/utils/helpers.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/customer/cart_controller.dart';
import '../../controllers/customer/order_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CheckoutView extends StatelessWidget {
  CheckoutView({super.key});

  final _address = TextEditingController();
  final _note = TextEditingController();
  final _payment = 'cash'.obs;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final orderCtrl = Get.find<OrderController>();
    final auth = Get.find<AuthController>();
    _address.text = auth.user?.defaultAddress ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Obx(() {
        if (cart.items.isEmpty) {
          return const Center(child: Text('Your cart is empty.'));
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery address',
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 10.h),
              CustomTextField(
                label: 'Address',
                hint: 'Street, building, apartment...',
                controller: _address,
                prefixIcon: const Icon(Icons.location_on_outlined),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 8.h),
              Text('Payment method',
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 10.h),
              Obx(() => Column(
                    children: [
                      _payTile('cash', 'Cash on delivery', Icons.money),
                      SizedBox(height: 8.h),
                      _payTile('card', 'Card', Icons.credit_card),
                      SizedBox(height: 8.h),
                      _payTile('wallet', 'Wallet', Icons.account_balance_wallet),
                    ],
                  )),
              SizedBox(height: 8.h),
              CustomTextField(
                label: 'Note for restaurant (optional)',
                hint: 'e.g. no onions',
                controller: _note,
                maxLines: 2,
              ),
              SizedBox(height: 8.h),
              Text('Order summary',
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Column(
                  children: [
                    _row('Subtotal', Helpers.formatCurrency(cart.subtotal)),
                    SizedBox(height: 6.h),
                    _row('Delivery', Helpers.formatCurrency(cart.deliveryFee)),
                    const Divider(height: 16),
                    _row('Total', Helpers.formatCurrency(cart.total),
                        bold: true, color: AppTheme.primary),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              CustomButton(
                label: 'Place order',
                isLoading: orderCtrl.isPlacing.value,
                onPressed: () async {
                  if (_address.text.trim().isEmpty) {
                    Helpers.showError('Please enter a delivery address.');
                    return;
                  }
                  final id = await orderCtrl.placeOrder(
                    paymentMethod: _payment.value,
                    note: _note.text.trim(),
                    address: _address.text.trim(),
                  );
                  if (id != null) {
                    Get.offAllNamed(AppRoutes.customerOrders);
                  }
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _payTile(String value, String label, IconData icon) {
    return Obx(() => GestureDetector(
          onTap: () => _payment.value = value,
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: _payment.value == value
                  ? AppTheme.primaryLight
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _payment.value == value
                    ? AppTheme.primary
                    : AppTheme.divider,
              ),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: _payment.value == value
                        ? AppTheme.primary
                        : AppTheme.textSecondary),
                SizedBox(width: 12.w),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                if (_payment.value == value)
                  const Icon(Icons.check_circle, color: AppTheme.primary),
              ],
            ),
          ),
        ));
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
