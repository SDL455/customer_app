import 'package:get/get.dart';
import '../../app/constants/app_constants.dart';
import '../../app/utils/helpers.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/restaurant_model.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

/// Merchant storefront management: products, incoming orders and store status.
class MerchantController extends GetxController {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  MerchantController(this._firestoreService, this._storageService);

  final Rxn<RestaurantModel> restaurant = Rxn<RestaurantModel>();
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;

  String get merchantId => Get.find<AuthController>().user?.uid ?? '';
  String get restaurantId => restaurant.value?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadRestaurant();
  }

  Future<void> _loadRestaurant() async {
    final uid = Get.find<AuthController>().user?.restaurantId;
    if (uid == null || uid.isEmpty) {
      isLoading.value = false;
      return;
    }
    final res = await _firestoreService.getRestaurantById(uid);
    res.fold((e) => isLoading.value = false, (r) {
      restaurant.value = r;
      if (r != null) _bindStreams(r.id);
      isLoading.value = false;
    });
  }

  void _bindStreams(String id) {
    _firestoreService
        .productsStream(id)
        .listen((list) => products.value = list);
    _firestoreService
        .merchantOrdersStream(id)
        .listen((list) => orders.value = list);
  }

  // ---------------- Products ----------------
  Future<bool> saveProduct({
    required String name,
    required String description,
    required double price,
    double? discountedPrice,
    required String categoryName,
    bool isPopular = false,
    String? existingId,
    String? imageUrl,
  }) async {
    final id = restaurantId;
    if (id.isEmpty) {
      Helpers.showError('No restaurant linked to this account.');
      return false;
    }
    final now = DateTime.now();
    if (existingId != null) {
      final existing = products.firstWhereOrNull((p) => p.id == existingId);
      if (existing == null) {
        // Product not yet in the local list (e.g. stream still loading) —
        // fall back to creating it as a new product.
        final product = ProductModel(
          id: existingId,
          restaurantId: id,
          name: name,
          description: description,
          price: price,
          discountedPrice: discountedPrice,
          categoryName: categoryName,
          isPopular: isPopular,
          imageUrl: imageUrl,
          createdAt: now,
        );
        final res = await _firestoreService.updateProduct(product);
        return res.fold((e) {
          Helpers.showError(e);
          return false;
        }, (_) {
          Helpers.showSuccess('Product updated');
          return true;
        });
      }
      final updated = existing.copyWith(
        name: name,
        description: description,
        price: price,
        discountedPrice: discountedPrice,
        // categoryName: categoryName,
        isPopular: isPopular,
        imageUrl: imageUrl ?? existing.imageUrl,
      );
      final res = await _firestoreService.updateProduct(updated);
      return res.fold((e) {
        Helpers.showError(e);
        return false;
      }, (_) {
        Helpers.showSuccess('Product updated');
        return true;
      });
    } else {
      final product = ProductModel(
        id: '',
        restaurantId: id,
        name: name,
        description: description,
        price: price,
        discountedPrice: discountedPrice,
        categoryName: categoryName,
        isPopular: isPopular,
        imageUrl: imageUrl,
        createdAt: now,
      );
      final res = await _firestoreService.addProduct(product);
      return res.fold((e) {
        Helpers.showError(e);
        return false;
      }, (_) {
        Helpers.showSuccess('Product added');
        return true;
      });
    }
  }

  Future<void> deleteProduct(String id) async {
    final ok = await Helpers.confirm(
        title: 'Delete product', message: 'This cannot be undone.');
    if (!ok) return;
    final res = await _firestoreService.deleteProduct(id);
    res.fold(
        (e) => Helpers.showError(e), (_) => Helpers.showSuccess('Deleted'));
  }

  Future<String?> pickAndUploadImage(String folder) async {
    final res = await _storageService.pickImage();
    return res.fold((e) {
      Helpers.showError(e);
      return null;
    }, (file) async {
      if (file == null) return null;
      final path = '$folder/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final up = await _storageService.uploadImage(file: file, path: path);
      return up.fold((e) {
        Helpers.showError(e);
        return null;
      }, (url) => url);
    });
  }

  // ---------------- Orders ----------------
  Future<void> acceptOrder(OrderModel order) async {
    final updated = order.copyWith(
      status: AppConstants.orderPreparing,
      // merchantId: merchantId,
      acceptedAt: DateTime.now(),
    );
    final res = await _firestoreService.updateOrder(updated);
    res.fold((e) => Helpers.showError(e),
        (_) => Helpers.showSuccess('Order accepted'));
  }

  Future<void> markReady(OrderModel order) async {
    final updated = order.copyWith(status: AppConstants.orderReady);
    final res = await _firestoreService.updateOrder(updated);
    res.fold((e) => Helpers.showError(e),
        (_) => Helpers.showInfo('Marked ready for pickup'));
  }

  Future<void> toggleStoreOpen() async {
    if (restaurant.value == null) return;
    final updated =
        restaurant.value!.copyWith(isOpen: !restaurant.value!.isOpen);
    final res = await _firestoreService.updateRestaurant(updated);
    res.fold((e) => Helpers.showError(e), (_) => restaurant.value = updated);
  }
}
