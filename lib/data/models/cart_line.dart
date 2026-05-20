import 'package:equatable/equatable.dart';

import 'product.dart';

class CartLine extends Equatable {
  const CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get lineTotal => product.price * quantity;

  CartLine copyWith({Product? product, int? quantity}) {
    return CartLine(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartLine.fromJson(Map<String, dynamic> json) {
    return CartLine(
      product: Product.fromStoredJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  @override
  List<Object?> get props =>
      [product.id, quantity, product.title, product.price];
}
