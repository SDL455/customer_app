import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodpanda_app/app/utils/validators.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/auth_layout.dart';

/// Shared sign-in screen for Customers, Merchants and Riders.
class LoginView extends StatelessWidget {
  LoginView({super.key});

  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return AuthLayout(
      title: 'Welcome back',
      subtitle: 'Sign in to continue to FoodPanda.',
      features: const [
        'Customers — order from top restaurants',
        'Merchants — manage your store & orders',
        'Riders — accept & complete deliveries',
      ],
      form: Form(
        key: _form,
        child: Column(
          children: [
            _field(
              label: 'Email',
              controller: _email,
              icon: Icons.email_outlined,
              validator: Validators.email,
            ),
            Obx(() => _field(
                  label: 'Password',
                  controller: _password,
                  icon: Icons.lock_outline,
                  obscure: auth.obscurePassword.value,
                  toggle: () => auth.togglePassword(),
                  validator: Validators.password,
                )),
            SizedBox(height: 8.h),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading.value
                        ? null
                        : () {
                            if (_form.currentState!.validate()) {
                              auth.login(
                                  email: _email.text, password: _password.text);
                            }
                          },
                    child: auth.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white)),
                          )
                        : const Text('Sign In'),
                  ),
                )),
            SizedBox(height: 14.h),
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
            SizedBox(height: 18.h),
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
                      style:
                          TextStyle(fontSize: 12, color: AppTheme.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggle,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              suffixIcon: toggle != null
                  ? IconButton(
                      icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: toggle,
                    )
                  : null,
              hintText: label,
            ),
          ),
        ],
      ),
    );
  }
}
