import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/merchant/merchant_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/network_image.dart';

class EditProductView extends StatelessWidget {
  EditProductView({super.key});

  final String id = Get.parameters['id'] ?? '';
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _discount = TextEditingController();
  final _category = TextEditingController();
  final _imageUrl = ''.obs;
  final _popular = false.obs;
  final _loaded = false.obs;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MerchantController>();
    final product = ctrl.products.firstWhereOrNull((p) => p.id == id);
    if (product != null && !_loaded.value) {
      _name.text = product.name;
      _desc.text = product.description ?? '';
      _price.text = product.price.toStringAsFixed(2);
      _discount.text = product.discountedPrice?.toStringAsFixed(2) ?? '';
      _category.text = product.categoryName ?? '';
      _imageUrl.value = product.imageUrl ?? '';
      _popular.value = product.isPopular;
      _loaded.value = true;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit product')),
      body: product == null
          ? const Center(child: Text('Product not found.'))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final url = await ctrl.pickAndUploadImage('products');
                        if (url != null) _imageUrl.value = url;
                      },
                      child: Obx(() => Container(
                            height: 150.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: _imageUrl.value.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_a_photo,
                                          color: AppTheme.primary, size: 32),
                                      SizedBox(height: 6),
                                      Text('Tap to change photo',
                                          style: TextStyle(
                                              color: AppTheme.primary)),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: NetImage(
                                      url: _imageUrl.value,
                                      height: 150.h,
                                      width: double.infinity,
                                      radius: 16,
                                    ),
                                  ),
                          )),
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      label: 'Product name',
                      controller: _name,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    CustomTextField(
                      label: 'Description',
                      controller: _desc,
                      maxLines: 3,
                    ),
                    CustomTextField(
                      label: 'Price',
                      controller: _price,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.attach_money),
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    CustomTextField(
                      label: 'Discounted price (optional)',
                      controller: _discount,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.local_offer),
                    ),
                    CustomTextField(
                      label: 'Category',
                      controller: _category,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    Obx(() => SwitchListTile(
                          title: const Text('Mark as popular'),
                          value: _popular.value,
                          activeColor: AppTheme.primary,
                          onChanged: (v) => _popular.value = v,
                        )),
                    SizedBox(height: 12.h),
                    CustomButton(
                      label: 'Update product',
                      onPressed: () async {
                        if (!_form.currentState!.validate()) return;
                        final ok = await ctrl.saveProduct(
                          name: _name.text.trim(),
                          description: _desc.text.trim(),
                          price: double.parse(_price.text.trim()),
                          discountedPrice: _discount.text.trim().isEmpty
                              ? null
                              : double.parse(_discount.text.trim()),
                          categoryName: _category.text.trim(),
                          isPopular: _popular.value,
                          existingId: id,
                          imageUrl: _imageUrl.value,
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
