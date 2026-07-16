import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a platform user. A single user document drives which role
/// experience is shown (customer / merchant / rider). Admin users live in the
/// separate admin project and are never created here.
class UserModel extends Equatable {
  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final String role; // customer | merchant | rider
  final String? photoUrl;
  final String? fcmToken;
  final DateTime createdAt;

  // Customer-only
  final String? defaultAddress;
  final double? defaultLat;
  final double? defaultLng;

  // Merchant-only
  final String? restaurantId; // link to the managed restaurant
  final bool merchantApproved;

  // Rider-only
  final bool isAvailable;
  final String? vehicleType; // bike | car | motorcycle
  final double? riderLat;
  final double? riderLng;
  final double riderRating;

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    this.photoUrl,
    this.fcmToken,
    required this.createdAt,
    this.defaultAddress,
    this.defaultLat,
    this.defaultLng,
    this.restaurantId,
    this.merchantApproved = false,
    this.isAvailable = false,
    this.vehicleType,
    this.riderLat,
    this.riderLng,
    this.riderRating = 0.0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      uid: id ?? map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'customer',
      photoUrl: map['photoUrl'],
      fcmToken: map['fcmToken'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      defaultAddress: map['defaultAddress'],
      defaultLat: (map['defaultLat'] as num?)?.toDouble(),
      defaultLng: (map['defaultLng'] as num?)?.toDouble(),
      restaurantId: map['restaurantId'],
      merchantApproved: map['merchantApproved'] ?? false,
      isAvailable: map['isAvailable'] ?? false,
      vehicleType: map['vehicleType'],
      riderLat: (map['riderLat'] as num?)?.toDouble(),
      riderLng: (map['riderLng'] as num?)?.toDouble(),
      riderRating: (map['riderRating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'defaultAddress': defaultAddress,
      'defaultLat': defaultLat,
      'defaultLng': defaultLng,
      'restaurantId': restaurantId,
      'merchantApproved': merchantApproved,
      'isAvailable': isAvailable,
      'vehicleType': vehicleType,
      'riderLat': riderLat,
      'riderLng': riderLng,
      'riderRating': riderRating,
    };
  }

  UserModel copyWith({
    String? fullName,
    String? phone,
    String? photoUrl,
    String? defaultAddress,
    double? defaultLat,
    double? defaultLng,
    String? restaurantId,
    bool? merchantApproved,
    bool? isAvailable,
    String? vehicleType,
    double? riderLat,
    double? riderLng,
    double? riderRating,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      defaultLat: defaultLat ?? this.defaultLat,
      defaultLng: defaultLng ?? this.defaultLng,
      restaurantId: restaurantId ?? this.restaurantId,
      merchantApproved: merchantApproved ?? this.merchantApproved,
      isAvailable: isAvailable ?? this.isAvailable,
      vehicleType: vehicleType ?? this.vehicleType,
      riderLat: riderLat ?? this.riderLat,
      riderLng: riderLng ?? this.riderLng,
      riderRating: riderRating ?? this.riderRating,
    );
  }

  bool get isCustomer => role == 'customer';
  bool get isMerchant => role == 'merchant';
  bool get isRider => role == 'rider';

  @override
  List<Object?> get props => [
        uid,
        email,
        fullName,
        phone,
        role,
        photoUrl,
        createdAt,
        restaurantId,
        isAvailable,
      ];
}
