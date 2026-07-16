import 'package:get/get.dart';

import '../../data/models/product_model.dart';
import '../../data/models/restaurant_model.dart';

/// A line item inside the cart.
class CartItem {
  final ProductModel product;
  final int quantity;
  final String? note;

  CartItem({required this.product, required this.quantity, this.note});

  double get total => product.effectivePrice * quantity;

  CartItem copyWith({int? quantity, String? note}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity, note: note);
}

/// App-wide shopping cart. Enforces a single-restaurant cart: adding an item
/// from a different restaurant clears the previous cart.
class CartController extends GetxController {
  final RxList<CartItem> items = <CartItem>[].obs;
  final Rxn<RestaurantModel> restaurant = Rxn<RestaurantModel>();

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.total);

  int get count => items.fold(0, (sum, item) => sum + item.quantity);

  double get deliveryFee =>
      restaurant.value?.deliveryFee ?? 2.0;

  double get total => subtotal + (items.isEmpty ? 0 : deliveryFee);

  void addToCart(ProductModel product, {RestaurantModel? fromRestaurant}) {
    if (fromRestaurant != null && restaurant.value != null) {
      if (restaurant.value!.id != fromRestaurant.id) {
        items.clear();
        restaurant.value = fromRestaurant;
      }
    } else if (fromRestaurant != null) {
      restaurant.value = fromRestaurant;
    }

    final idx = items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      final existing = items[idx];
      items[idx] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }
    items.refresh();
  }

  void increment(String productId) {
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      final e = items[idx];
      items[idx] = e.copyWith(quantity: e.quantity + 1);
      items.refresh();
    }
  }

  void decrement(String productId) {
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      final e = items[idx];
      if (e.quantity <= 1) {
        items.removeAt(idx);
        if (items.isEmpty) restaurant.value = null;
      } else {
        items[idx] = e.copyWith(quantity: e.quantity - 1);
        items.refresh();
      }
    }
  }

  void updateNote(String productId, String note) {
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(note: note);
      items.refresh();
    }
  }

  void remove(String productId) {
    items.removeWhere((i) => i.product.id == productId);
    if (items.isEmpty) restaurant.value = null;
  }

  void clear() {
    items.clear();
    restaurant.value = null;
  }
}
