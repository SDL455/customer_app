/// Application-wide constants and configuration.
class AppConstants {
  // Firebase collection names
  static const String usersCollection = 'users';
  static const String categoriesCollection = 'categories';
  static const String restaurantsCollection = 'restaurants';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String reviewsCollection = 'reviews';

  // User roles
  static const String roleCustomer = 'customer';
  static const String roleMerchant = 'merchant';
  static const String roleRider = 'rider';
  static const String roleAdmin = 'admin';

  // Order statuses (shared across the platform)
  static const String orderPending = 'pending'; // awaiting merchant acceptance
  static const String orderAccepted = 'accepted'; // merchant accepted, searching rider
  static const String orderPreparing = 'preparing';
  static const String orderReady = 'ready'; // ready for pickup
  static const String orderPickedUp = 'picked_up'; // rider picked up
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // App meta
  static const String appName = 'FoodPanda';
  static const String appTagline = 'Food delivery at your doorstep';

  // Pagination / limits
  static const int pageSize = 20;
  static const double defaultDeliveryFee = 2.0;
  static const double freeDeliveryThreshold = 30.0;

  // Storage keys
  static const String boxUsers = 'fp_users';
  static const String boxAuth = 'fp_auth';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyLanguage = 'language';
}
