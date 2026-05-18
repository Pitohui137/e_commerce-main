import 'package:equatable/equatable.dart';
import '../../../data/models/product.dart';

sealed class JualState extends Equatable {
  const JualState();
  @override
  List<Object?> get props => [];
}

class JualLoaded extends JualState {
  const JualLoaded(this.products);
  final List<Product> products;
  @override
  List<Object?> get props => [products];
}