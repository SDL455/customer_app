import 'package:get/get.dart';

import '../../app/constants/app_constants.dart';
import '../../app/utils/helpers.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/customer/cart_controller.dart';
import '../../data/models/order_model.dart';
import '../../data/models/review_model.dart';
import '../../services/firestore_service.dart';

/// Customer order lifecycle: placing, listing and reviewing orders.
class OrderController extends GetxController {
  final FirestoreService _firestoreService;

  OrderController(this._firestoreService);

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isPlacing = false.obs;

  String get customerId => Get.find<AuthController>().user?.uid ?? '';
  String get customerName => Get.find<AuthController>().user?.fullName ?? '';
  String? get customerPhone => Get.find<AuthController>().user?.phone;

  void bindCustomerOrders() {
    if (customerId.isEmpty) return;
    _firestoreService.customerOrdersStream(customerId).listen((list) {
      orders.value = list;
    });
  }

  Future<String?> placeOrder({
    required String paymentMethod,
    String? note,
    String? address,
    double? lat,
    double? lng,
  }) async {
    final cart = Get.find<CartController>();
    if (cart.items.isEmpty) {
      Helpers.showError('Your cart is empty.');
      return null;
    }
    isPlacing.value = true;
    final order = OrderModel(
      id: '', // assigned by Firestore
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      restaurantId: cart.restaurant.value?.id ?? '',
      restaurantName: cart.restaurant.value?.name ?? '',
      items: cart.items
          .map((i) => OrderItem(
                productId: i.product.id,
                name: i.product.name,
                imageUrl: i.product.imageUrl,
                price: i.product.effectivePrice,
                quantity: i.quantity,
                note: i.note,
              ))
          .toList(),
      subtotal: cart.subtotal,
      deliveryFee: cart.deliveryFee,
      total: cart.total,
      status: AppConstants.orderPending,
      paymentMethod: paymentMethod,
      deliveryAddress: address,
      deliveryLat: lat,
      deliveryLng: lng,
      note: note,
      createdAt: DateTime.now(),
      estimatedMinutes: cart.restaurant.value?.deliveryTimeMin ?? 30,
    );

    final result = await _firestoreService.placeOrder(order);
    isPlacing.value = false;
    return result.fold(
      (err) {
        Helpers.showError(err);
        return null;
      },
      (id) {
        cart.clear();
        Helpers.showSuccess('Order placed successfully!');
        return id;
      },
    );
  }

  Future<void> addReview({
    required OrderModel order,
    required double rating,
    String? comment,
  }) async {
    final review = ReviewModel(
      id: '',
      orderId: order.id,
      restaurantId: order.restaurantId,
      customerId: customerId,
      customerName: customerName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    final res = await _firestoreService.addReview(review);
    res.fold((e) => Helpers.showError(e), (_) => Helpers.showSuccess('Thanks for your review!'));
  }
}
