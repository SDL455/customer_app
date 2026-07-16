import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/customer/cart_controller.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

/// Global, app-wide dependencies (services + auth + cart). Registered as
/// permanent singletons so every feature controller can resolve them via
/// [Get.find], and the cart survives bottom-navigation between tabs.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(FirestoreService(), permanent: true);
    Get.put(StorageService(), permanent: true);
    Get.put(
      AuthController(Get.find<AuthService>(), Get.find<FirestoreService>()),
      permanent: true,
    );
    Get.put(CartController(), permanent: true);
  }
}
