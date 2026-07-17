import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A menu item sold by a restaurant. Managed by the merchant from this app.
class ProductModel extends Equatable {
  final String id;
  final String restaurantId;
  final String name;
  final String? description;
  final String? imageUrl;
  final double price;
  final double? discountedPrice;
  final String? categoryId;
  final String? categoryName;
  final bool isAvailable;
  final bool isPopular;
  final int stock;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.price,
    this.discountedPrice,
    this.categoryId,
    this.categoryName,
    this.isAvailable = true,
    this.isPopular = false,
    this.stock = 999,
    required this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      restaurantId: map['restaurantId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (map['discountedPrice'] as num?)?.toDouble(),
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      isAvailable: map['isAvailable'] ?? true,
      isPopular: map['isPopular'] ?? false,
      stock: (map['stock'] as num?)?.toInt() ?? 999,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'restaurantId': restaurantId,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'price': price,
        'discountedPrice': discountedPrice,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'isAvailable': isAvailable,
        'isPopular': isPopular,
        'stock': stock,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  double get effectivePrice => discountedPrice ?? price;

  bool get hasDiscount =>
      discountedPrice != null && discountedPrice! < price;

  ProductModel copyWith({
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    double? discountedPrice,
    String? categoryId,
    String? categoryName,
    bool? isAvailable,
    bool? isPopular,
    int? stock,
  }) {
    return ProductModel(
      id: id,
      restaurantId: restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isAvailable: isAvailable ?? this.isAvailable,
      isPopular: isPopular ?? this.isPopular,
      stock: stock ?? this.stock,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        name,
        price,
        isAvailable,
      ];
}
