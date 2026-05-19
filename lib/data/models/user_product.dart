import 'package:equatable/equatable.dart';

import 'product.dart';

class UserProduct extends Equatable {
  const UserProduct({
    required this.id,
    required this.userId,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final DateTime createdAt;

  factory UserProduct.fromJson(Map<String, dynamic> json) {
    return UserProduct(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Product toDisplayProduct() {
    return Product(
      id: id.hashCode,
      title: title,
      price: price,
      description: description,
      category: category,
      image: imageUrl,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, title, price, description, category, imageUrl, createdAt];
}
