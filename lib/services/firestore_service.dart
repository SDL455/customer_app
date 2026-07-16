import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../app/constants/app_constants.dart';
import '../data/models/category_model.dart';
import '../data/models/order_model.dart';
import '../data/models/product_model.dart';
import '../data/models/restaurant_model.dart';
import '../data/models/review_model.dart';

/// Thin wrapper around Cloud Firestore for the most common read/write/stream
/// operations used across the customer, merchant and rider experiences.
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  // -------------------- Restaurants --------------------
  Stream<List<RestaurantModel>> restaurantsStream({bool approvedOnly = true}) {
    var q = _db
        .collection(AppConstants.restaurantsCollection)
        .orderBy('rating', descending: true);
    if (approvedOnly) {
      q = q.where('isApproved', isEqualTo: true);
    }
    return q.snapshots().map((snap) => snap.docs
        .map((d) => RestaurantModel.fromMap(d.data(), d.id))
        .toList());
  }

  Future<Either<String, List<RestaurantModel>>> getRestaurants() async {
    try {
      final snap = await _db
          .collection(AppConstants.restaurantsCollection)
          .where('isApproved', isEqualTo: true)
          .get();
      final list = snap.docs
          .map((d) => RestaurantModel.fromMap(d.data(), d.id))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Stream<RestaurantModel?> restaurantStream(String id) {
    return _db
        .collection(AppConstants.restaurantsCollection)
        .doc(id)
        .snapshots()
        .map((d) => d.exists ? RestaurantModel.fromMap(d.data()!, d.id) : null);
  }

  Future<Either<String, RestaurantModel?>> getRestaurantById(String id) async {
    try {
      final d =
          await _db.collection(AppConstants.restaurantsCollection).doc(id).get();
      return Right(d.exists ? RestaurantModel.fromMap(d.data()!, d.id) : null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> updateRestaurant(RestaurantModel r) async {
    try {
      await _db
          .collection(AppConstants.restaurantsCollection)
          .doc(r.id)
          .update(r.toMap());
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // -------------------- Categories --------------------
  Stream<List<CategoryModel>> categoriesStream() {
    return _db
        .collection(AppConstants.categoriesCollection)
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CategoryModel.fromMap(d.data(), d.id))
            .toList());
  }

  // -------------------- Products --------------------
  Stream<List<ProductModel>> productsStream(String restaurantId) {
    return _db
        .collection(AppConstants.productsCollection)
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('isPopular', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ProductModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<Either<String, void>> addProduct(ProductModel p) async {
    try {
      await _db.collection(AppConstants.productsCollection).add(p.toMap());
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> updateProduct(ProductModel p) async {
    try {
      await _db
          .collection(AppConstants.productsCollection)
          .doc(p.id)
          .update(p.toMap());
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> deleteProduct(String id) async {
    try {
      await _db.collection(AppConstants.productsCollection).doc(id).delete();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // -------------------- Orders --------------------
  Future<Either<String, String>> placeOrder(OrderModel order) async {
    try {
      final ref = await _db
          .collection(AppConstants.ordersCollection)
          .add(order.toMap());
      return Right(ref.id);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Stream<List<OrderModel>> customerOrdersStream(String customerId) {
    return _db
        .collection(AppConstants.ordersCollection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_ordersFrom);
  }

  Stream<List<OrderModel>> merchantOrdersStream(String restaurantId) {
    return _db
        .collection(AppConstants.ordersCollection)
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_ordersFrom);
  }

  Stream<List<OrderModel>> availableRiderOrdersStream() {
    return _db
        .collection(AppConstants.ordersCollection)
        .where('status', whereIn: ['accepted', 'preparing', 'ready'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_ordersFrom);
  }

  Stream<List<OrderModel>> riderActiveOrdersStream(String riderId) {
    return _db
        .collection(AppConstants.ordersCollection)
        .where('riderId', isEqualTo: riderId)
        .where('status', whereIn: ['picked_up', 'accepted', 'preparing', 'ready'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_ordersFrom);
  }

  Future<Either<String, void>> updateOrder(OrderModel order) async {
    try {
      await _db
          .collection(AppConstants.ordersCollection)
          .doc(order.id)
          .update(order.toMap());
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Stream<OrderModel?> orderStream(String orderId) {
    return _db
        .collection(AppConstants.ordersCollection)
        .doc(orderId)
        .snapshots()
        .map((d) => d.exists ? OrderModel.fromMap(d.data()!, d.id) : null);
  }

  // -------------------- Reviews --------------------
  Future<Either<String, void>> addReview(ReviewModel review) async {
    try {
      await _db.collection(AppConstants.reviewsCollection).add(review.toMap());
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  List<OrderModel> _ordersFrom(QuerySnapshot snap) =>
      snap.docs.map((d) => OrderModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
}
