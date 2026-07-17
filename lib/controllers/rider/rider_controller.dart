import 'package:get/get.dart';

import '../../app/constants/app_constants.dart';
import '../../app/utils/helpers.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/order_model.dart';
import '../../services/firestore_service.dart';

/// Rider delivery workflow: browse available orders, accept, pick up and
/// complete deliveries.
class RiderController extends GetxController {
  final FirestoreService _firestoreService;

  RiderController(this._firestoreService);

  final RxList<OrderModel> availableOrders = <OrderModel>[].obs;
  final RxList<OrderModel> myOrders = <OrderModel>[].obs;
  final RxBool isAvailable = false.obs;
  final RxBool isLoading = true.obs;

  String get riderId => Get.find<AuthController>().user?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    isAvailable.value = Get.find<AuthController>().user?.isAvailable ?? false;
    _bind();
  }

  Future<void> toggleAvailability() async {
    final auth = Get.find<AuthController>();
    final user = auth.user;
    if (user == null) return;
    isAvailable.toggle();
    final updated = user.copyWith(isAvailable: isAvailable.value);
    final res = await auth.updateCurrentUser(updated);
    res.fold(
      (e) {},
      (_) => Helpers.showInfo(
          isAvailable.value ? 'You are now online' : 'You are offline'),
    );
  }

  void _bind() {
    _firestoreService.availableRiderOrdersStream().listen((list) {
      availableOrders.value = list.where((o) => o.riderId == null).toList();
    });
    _firestoreService.riderActiveOrdersStream(riderId).listen((list) {
      myOrders.value = list;
      isLoading.value = false;
    });
  }

  Future<void> acceptOrder(OrderModel order) async {
    if (!isAvailable.value) {
      Helpers.showError('Go online to accept orders.');
      return;
    }
    final updated = order.copyWith(
      riderId: riderId,
      status: AppConstants.orderAccepted,
      acceptedAt: DateTime.now(),
    );
    final res = await _firestoreService.updateOrder(updated);
    res.fold((e) => Helpers.showError(e), (_) => Helpers.showSuccess('Order accepted'));
  }

  Future<void> pickUp(OrderModel order) async {
    final updated = order.copyWith(
      status: AppConstants.orderPickedUp,
      pickedUpAt: DateTime.now(),
    );
    final res = await _firestoreService.updateOrder(updated);
    res.fold((e) => Helpers.showError(e), (_) => Helpers.showInfo('Picked up — on the way!'));

  }

  Future<void> completeDelivery(OrderModel order) async {
    final updated = order.copyWith(
      status: AppConstants.orderDelivered,
      deliveredAt: DateTime.now(),
      isPaid: order.paymentMethod == 'cash' ? true : order.isPaid,
    );
    final res = await _firestoreService.updateOrder(updated);
    res.fold((e) => Helpers.showError(e), (_) => Helpers.showSuccess('Delivered. Thank you!'));

  }
}
