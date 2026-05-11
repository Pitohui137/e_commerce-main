import 'package:equatable/equatable.dart';

import '../../../data/models/cart_line.dart';

class CartState extends Equatable {
  const CartState({required this.lines});

  final List<CartLine> lines;

  double get grandTotal => lines.fold(0.0, (sum, line) => sum + line.lineTotal);

  bool get isEmpty => lines.isEmpty;

  @override
  List<Object?> get props => [lines];
}
