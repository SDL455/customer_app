/// Centralized route names for the Customer / Merchant / Rider app.
class AppRoutes {
  // Core
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const roleLanding = '/role-landing';

  // Customer
  static const customerHome = '/customer/home';
  static const restaurantDetail = '/customer/restaurant/:id';
  static const cart = '/customer/cart';
  static const checkout = '/customer/checkout';
  static const customerOrders = '/customer/orders';
  static const customerProfile = '/customer/profile';
  static const customerOrderDetail = '/customer/order/:id';

  // Merchant
  static const merchantHome = '/merchant/home';
  static const merchantOrders = '/merchant/orders';
  static const merchantAddProduct = '/merchant/product/add';
  static const merchantEditProduct = '/merchant/product/edit/:id';
  static const merchantProfile = '/merchant/profile';
  static const merchantEditStore = '/merchant/store/edit';

  // Rider
  static const riderHome = '/rider/home';
  static const riderOrders = '/rider/orders';
  static const riderProfile = '/rider/profile';

  AppRoutes._();
}
