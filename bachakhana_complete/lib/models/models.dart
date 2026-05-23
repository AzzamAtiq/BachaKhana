import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ══════════════════════
// SLOT
// ══════════════════════
class SlotModel {
  final String name;
  int avail;
  final List<String> times;
  final String desc;
  final int origPrice;
  final int bagPrice;

  SlotModel({required this.name, required this.avail, required this.times,
    required this.desc, required this.origPrice, required this.bagPrice});

  factory SlotModel.fromMap(Map<String, dynamic> m) => SlotModel(
    name: m['name'] ?? '', avail: m['avail'] ?? 0,
    times: List<String>.from(m['times'] ?? []),
    desc: m['desc'] ?? '', origPrice: m['origPrice'] ?? 0,
    bagPrice: m['bagPrice'] ?? 0);

  Map<String, dynamic> toMap() => {
    'name': name, 'avail': avail, 'times': times,
    'desc': desc, 'origPrice': origPrice, 'bagPrice': bagPrice};
}

// ══════════════════════
// REVIEW
// ══════════════════════
class ReviewModel {
  final String user;
  final String stars;
  final String text;
  final DateTime? createdAt;

  const ReviewModel({required this.user, required this.stars,
    required this.text, this.createdAt});

  factory ReviewModel.fromMap(Map<String, dynamic> m) => ReviewModel(
    user: m['user'] ?? '', stars: m['stars'] ?? '⭐⭐⭐⭐⭐',
    text: m['text'] ?? '',
    createdAt: (m['createdAt'] as Timestamp?)?.toDate());

  Map<String, dynamic> toMap() => {
    'user': user, 'stars': stars, 'text': text,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null};
}

// ══════════════════════
// RESTAURANT
// ══════════════════════
class RestaurantModel {
  final String firestoreId;
  final int id;
  final String name;
  final String category;
  final String emoji;
  final List<String> gradientHex;
  final String location;
  final String city;
  final double distance;
  final double rating;
  final int reviewCount;
  final String badge;
  final String badgeType;
  final bool hasDelivery;
  final int deliveryCharge;
  final String deliveryTime;
  final int bagPrice;
  final int origPrice;
  int bagsLeft;
  final String timer;
  final List<SlotModel> slots;
  final List<String> tags;
  final List<ReviewModel> reviews;
  final String ownerId;
  final bool isApproved;
  final DateTime? createdAt;
  // Phase 4 - Maps
  final double latitude;
  final double longitude;

  RestaurantModel({
    required this.firestoreId, required this.id, required this.name,
    required this.category, required this.emoji, required this.gradientHex,
    required this.location, required this.city, required this.distance,
    required this.rating, required this.reviewCount, required this.badge,
    required this.badgeType, required this.hasDelivery,
    required this.deliveryCharge, required this.deliveryTime,
    required this.bagPrice, required this.origPrice, required this.bagsLeft,
    required this.timer, required this.slots, required this.tags,
    required this.reviews, this.ownerId = '', this.isApproved = true,
    this.createdAt, this.latitude = 33.6844, this.longitude = 73.0479,
  });

  int get discount => ((1 - bagPrice / origPrice) * 100).round();
  int get savings  => origPrice - bagPrice;

  List<Color> get gradientColors => gradientHex.map((h) {
    final hex = h.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }).toList();

  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return RestaurantModel(
      firestoreId: doc.id, id: m['id'] ?? 0, name: m['name'] ?? '',
      category: m['category'] ?? '', emoji: m['emoji'] ?? '🍽️',
      gradientHex: List<String>.from(m['gradientHex'] ?? ['#1B4332','#2D6A4F']),
      location: m['location'] ?? '', city: m['city'] ?? '',
      distance: (m['distance'] ?? 0).toDouble(),
      rating: (m['rating'] ?? 4.5).toDouble(),
      reviewCount: m['reviewCount'] ?? 0,
      badge: m['badge'] ?? '', badgeType: m['badgeType'] ?? 'blue',
      hasDelivery: m['hasDelivery'] ?? false,
      deliveryCharge: m['deliveryCharge'] ?? 0,
      deliveryTime: m['deliveryTime'] ?? '',
      bagPrice: m['bagPrice'] ?? 0, origPrice: m['origPrice'] ?? 0,
      bagsLeft: m['bagsLeft'] ?? 0, timer: m['timer'] ?? '',
      slots: (m['slots'] as List? ?? []).map((s) => SlotModel.fromMap(s)).toList(),
      tags: List<String>.from(m['tags'] ?? []),
      reviews: (m['reviews'] as List? ?? []).map((r) => ReviewModel.fromMap(r)).toList(),
      ownerId: m['ownerId'] ?? '', isApproved: m['isApproved'] ?? false,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
      latitude: (m['latitude'] ?? 33.6844).toDouble(),
      longitude: (m['longitude'] ?? 73.0479).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'id': id, 'name': name, 'category': category, 'emoji': emoji,
    'gradientHex': gradientHex, 'location': location, 'city': city,
    'distance': distance, 'rating': rating, 'reviewCount': reviewCount,
    'badge': badge, 'badgeType': badgeType, 'hasDelivery': hasDelivery,
    'deliveryCharge': deliveryCharge, 'deliveryTime': deliveryTime,
    'bagPrice': bagPrice, 'origPrice': origPrice, 'bagsLeft': bagsLeft,
    'timer': timer, 'slots': slots.map((s) => s.toMap()).toList(),
    'tags': tags, 'reviews': reviews.map((r) => r.toMap()).toList(),
    'ownerId': ownerId, 'isApproved': isApproved, 'latitude': latitude,
    'longitude': longitude,
    'createdAt': createdAt != null
      ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
  };
}

// ══════════════════════
// ORDER
// ══════════════════════
class OrderModel {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String emoji;
  final String bagName;
  final String? pickupTime;
  final int price;
  final int saved;
  final DateTime createdAt;
  final bool isDelivery;
  final String userId;
  String status; // 'confirmed' | 'picked_up' | 'cancelled'
  final String paymentMethod;
  final String paymentStatus; // 'paid' | 'pending' | 'failed'
  final String? transactionId;

  OrderModel({
    required this.id, required this.restaurantId,
    required this.restaurantName, required this.emoji,
    required this.bagName, this.pickupTime, required this.price,
    required this.saved, required this.createdAt, required this.isDelivery,
    required this.userId, this.status = 'confirmed',
    this.paymentMethod = 'jazzcash', this.paymentStatus = 'paid',
    this.transactionId,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id, restaurantId: m['restaurantId'] ?? '',
      restaurantName: m['restaurantName'] ?? '', emoji: m['emoji'] ?? '🍱',
      bagName: m['bagName'] ?? 'Surprise Bag', pickupTime: m['pickupTime'],
      price: m['price'] ?? 0, saved: m['saved'] ?? 0,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDelivery: m['isDelivery'] ?? false, userId: m['userId'] ?? '',
      status: m['status'] ?? 'confirmed',
      paymentMethod: m['paymentMethod'] ?? 'jazzcash',
      paymentStatus: m['paymentStatus'] ?? 'paid',
      transactionId: m['transactionId'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'restaurantId': restaurantId, 'restaurantName': restaurantName,
    'emoji': emoji, 'bagName': bagName, 'pickupTime': pickupTime,
    'price': price, 'saved': saved, 'createdAt': Timestamp.fromDate(createdAt),
    'isDelivery': isDelivery, 'userId': userId, 'status': status,
    'paymentMethod': paymentMethod, 'paymentStatus': paymentStatus,
    'transactionId': transactionId,
  };
}

// ══════════════════════
// USER
// ══════════════════════
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String city;
  final List<String> favoriteIds;
  final String? deliveryAddress;
  final DateTime? createdAt;

  const UserModel({
    required this.uid, required this.name, required this.email,
    required this.phone, required this.city,
    this.favoriteIds = const [], this.deliveryAddress, this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id, name: m['name'] ?? '', email: m['email'] ?? '',
      phone: m['phone'] ?? '', city: m['city'] ?? 'Rawalpindi',
      favoriteIds: List<String>.from(m['favoriteIds'] ?? []),
      deliveryAddress: m['deliveryAddress'],
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name, 'email': email, 'phone': phone, 'city': city,
    'favoriteIds': favoriteIds, 'deliveryAddress': deliveryAddress,
    'createdAt': createdAt != null
      ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
  };

  UserModel copyWith({String? name, String? phone, String? city,
    List<String>? favoriteIds, String? deliveryAddress}) => UserModel(
    uid: uid, name: name ?? this.name, email: email,
    phone: phone ?? this.phone, city: city ?? this.city,
    favoriteIds: favoriteIds ?? this.favoriteIds,
    deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    createdAt: createdAt,
  );
}

// ══════════════════════
// NOTIFICATION
// ══════════════════════
class NotifModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'deal' | 'order' | 'impact'
  final bool isRead;
  final DateTime createdAt;

  const NotifModel({
    required this.id, required this.title, required this.body,
    required this.type, this.isRead = false, required this.createdAt,
  });
}
