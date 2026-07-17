import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/merchant/merchant_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Edit the merchant's storefront details (name, description, address,
/// delivery fee, min order and estimated time).
class EditStoreView extends StatelessWidget {
  EditStoreView({super.key});

  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _address = TextEditingController();
  final _fee = TextEditingController();
  final _min = TextEditingController();
  final _time = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MerchantController>();
    final r = ctrl.restaurant.value;
    if (r != null) {
      _name.text = r.name;
      _desc.text = r.description ?? '';
      _address.text = r.address ?? '';
      _fee.text = r.deliveryFee.toStringAsFixed(2);
      _min.text = r.minOrder.toStringAsFixed(2);
      _time.text = r.deliveryTimeMin.toString();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Store details')),
      body: r == null
          ? const Center(child: Text('No store linked to this account.'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Store name',
                      controller: _name,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    CustomTextField(
                      label: 'Description',
                      controller: _desc,
                      maxLines: 3,
                    ),
                    CustomTextField(
                      label: 'Address',
                      controller: _address,
                      maxLines: 2,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    CustomTextField(
                      label: 'Delivery fee',
                      controller: _fee,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.attach_money),
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    CustomTextField(
                      label: 'Minimum order',
                      controller: _min,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.shopping_bag),
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    CustomTextField(
                      label: 'Estimated delivery time (minutes)',
                      controller: _time,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.timer),
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    CustomButton(
                      label: 'Save changes',
                      onPressed: () async {
                        if (!_form.currentState!.validate()) return;
                        final ok = await ctrl.saveStoreDetails(
                          name: _name.text.trim(),
                          description: _desc.text.trim(),
                          address: _address.text.trim(),
                          deliveryFee: double.parse(_fee.text.trim()),
                          minOrder: double.parse(_min.text.trim()),
                          deliveryTimeMin: int.parse(_time.text.trim()),
                        );
                        if (ok) Get.back();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
