import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../app/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Customer self-registration. Merchants/Riders are provisioned by admin.
class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Join as a Customer',
                    style: TextStyle(
                        fontSize: 22.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                const Text('Order food from your favorite restaurants.',
                    style: TextStyle(color: AppTheme.textSecondary)),
                SizedBox(height: 20.h),
                CustomTextField(
                  label: 'Full name',
                  hint: 'Jane Doe',
                  controller: _name,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (v) => Validators.required(v, field: 'Name'),
                ),
                CustomTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.email,
                ),
                CustomTextField(
                  label: 'Phone',
                  hint: '+856 20 1234 5678',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: Validators.phone,
                ),
                Obx(() => CustomTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _password,
                  obscureText: auth.obscurePassword.value,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(auth.obscurePassword.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: auth.togglePassword,
                  ),
                  validator: Validators.password,
                )),
                CustomTextField(
                  label: 'Confirm password',
                  hint: '••••••••',
                  controller: _confirm,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (v) => Validators.confirmPassword(v, _password.text),
                ),
                SizedBox(height: 8.h),
                Obx(() => CustomButton(
                  label: 'Create account',
                  isLoading: auth.isLoading.value,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      auth.registerCustomer(
                        fullName: _name.text,
                        email: _email.text,
                        password: _password.text,
                        phone: _phone.text,
                      );
                    }
                  },
                )),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ',
                        style: TextStyle(color: AppTheme.textSecondary)),
                    GestureDetector(
                      onTap: () => Get.offNamed(AppRoutes.login),
                      child: Text('Sign in',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
