import 'package:foodpanda_app/app/routes/app_routes.dart';
import 'package:get/get.dart';

import '../../views/splash/splash_view.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/register_view.dart';
import '../../views/role_landing/role_landing_view.dart';
import '../../views/customer/home_view.dart';
import '../../views/customer/restaurant_detail_view.dart';
import '../../views/customer/cart_view.dart';
import '../../views/customer/checkout_view.dart';
import '../../views/customer/orders_view.dart';
import '../../views/customer/order_detail_view.dart';
import '../../views/customer/profile_view.dart';
import '../../views/merchant/home_view.dart';
import '../../views/merchant/orders_view.dart';
import '../../views/merchant/add_product_view.dart';
import '../../views/merchant/edit_product_view.dart';
import '../../views/merchant/profile_view.dart';
import '../../views/rider/home_view.dart';
import '../../views/rider/orders_view.dart';
import '../../views/rider/profile_view.dart';

import '../../controllers/customer/home_controller.dart';
import '../../controllers/customer/order_controller.dart';
import '../../controllers/merchant/merchant_controller.dart';
import '../../controllers/rider/rider_controller.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

/// Application route table (GetX). Services, AuthController and CartController
/// are provided by [InitialBinding]; the remaining feature controllers are
/// lazily bound per route so they are (re)created when their screen is shown.
class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView()),
    GetPage(name: AppRoutes.login, page: () => LoginView()),
    GetPage(name: AppRoutes.register, page: () => RegisterView()),
    GetPage(
      name: AppRoutes.roleLanding,
      page: () => const RoleLandingView(),
      binding: BindingsBuilder(() =>
          Get.lazyPut(() => HomeController(Get.find<FirestoreService>()))),
    ),
    // ---------------- Customer ----------------
    GetPage(
      name: AppRoutes.customerHome,
      page: () => const CustomerHomeView(),
      binding: BindingsBuilder(() =>
          Get.lazyPut(() => HomeController(Get.find<FirestoreService>()))),
    ),
    GetPage(
      name: AppRoutes.restaurantDetail,
      page: () => RestaurantDetailView(),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => CartView(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => CheckoutView(),
      binding: BindingsBuilder(() =>
          Get.lazyPut(() => OrderController(Get.find<FirestoreService>()))),
    ),
    GetPage(
      name: AppRoutes.customerOrders,
      page: () => const CustomerOrdersView(),
      binding: BindingsBuilder(() =>
          Get.lazyPut(() => OrderController(Get.find<FirestoreService>()))),
    ),
    GetPage(
      name: AppRoutes.customerOrderDetail,
      page: () => CustomerOrderDetailView(),
      binding: BindingsBuilder(() =>
          Get.lazyPut(() => OrderController(Get.find<FirestoreService>()))),
    ),
    GetPage(
      name: AppRoutes.customerProfile,
      page: () => const CustomerProfileView(),
    ),
    // ---------------- Merchant ----------------
    GetPage(
      name: AppRoutes.merchantHome,
      page: () => const MerchantHomeView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => MerchantController(
            Get.find<FirestoreService>(),
            Get.find<StorageService>(),
          ))),
    ),
    GetPage(
      name: AppRoutes.merchantOrders,
      page: () => const MerchantOrdersView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => MerchantController(
            Get.find<FirestoreService>(),
            Get.find<StorageService>(),
          ))),
    ),
    GetPage(
      name: AppRoutes.merchantAddProduct,
      page: () => AddProductView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => MerchantController(
            Get.find<FirestoreService>(),
            Get.find<StorageService>(),
          ),
        ),
      ),
    ),
    GetPage(
      name: AppRoutes.merchantEditProduct,
      page: () => EditProductView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => MerchantController(
            Get.find<FirestoreService>(),
            Get.find<StorageService>(),
          ))),
    ),
    GetPage(
      name: AppRoutes.merchantProfile,
      page: () => const MerchantProfileView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => MerchantController(
            Get.find<FirestoreService>(),
            Get.find<StorageService>(),
          ))),
    ),
    // ---------------- Rider ----------------
    GetPage(
      name: AppRoutes.riderHome,
      page: () => const RiderHomeView(),
      binding: BindingsBuilder(() =>
          Get.lazyPut(() => RiderController(Get.find<FirestoreService>()))),
    ),
    GetPage(
      name: AppRoutes.riderOrders,
      page: () => const RiderOrdersView(),
      binding: BindingsBuilder(() =>
          Get.lazyPut(() => RiderController(Get.find<FirestoreService>()))),
    ),
    GetPage(
      name: AppRoutes.riderProfile,
      page: () => const RiderProfileView(),
      binding: BindingsBuilder(() =>
          Get.lazyPut(() => RiderController(Get.find<FirestoreService>()))),
    ),
  ];
}
