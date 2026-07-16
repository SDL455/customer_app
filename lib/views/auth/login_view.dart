import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../app/utils/validators.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Shared sign-in screen for Customers, Merchants and Riders.
class LoginView extends StatelessWidget {
  LoginView({super.key});

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delivery_dining,
                        size: 52.sp, color: AppTheme.primary),
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: Text('Welcome back',
                      style: TextStyle(
                          fontSize: 24.sp, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 6.h),
                Center(
                  child: Text(
                    'Sign in to continue to FoodPanda',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                SizedBox(height: 28.h),
                CustomTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.email,
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
                SizedBox(height: 8.h),
                Obx(() => CustomButton(
                  label: 'Sign In',
                  isLoading: auth.isLoading.value,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      auth.login(email: _email.text, password: _password.text);
                    }
                  },
                )),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New here? ",
                        style: TextStyle(color: AppTheme.textSecondary)),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.register),
                      child: Text('Create a customer account',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Merchant & Rider accounts are created by the admin. '
                          'If you are one, sign in with the credentials provided.',
                          style: TextStyle(fontSize: 12, color: AppTheme.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
