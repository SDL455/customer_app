import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/constants/app_constants.dart';
import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';

/// Post-authentication hub that routes to the correct home for the user's role.
/// Normally [AuthController.boot] already redirects here; this screen is a
/// safe fallback if reached directly.
class RoleLandingView extends StatelessWidget {
  const RoleLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = auth.user?.role;
      switch (role) {
        case AppConstants.roleMerchant:
          Get.offAllNamed(AppRoutes.merchantHome);
          break;
        case AppConstants.roleRider:
          Get.offAllNamed(AppRoutes.riderHome);
          break;
        default:
          Get.offAllNamed(AppRoutes.customerHome);
      }
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFFE21B70))),
    );
  }
}
