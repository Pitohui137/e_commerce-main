import 'package:equatable/equatable.dart';

import '../../../data/models/product.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.products,
    required this.categories,
    this.selectedCategory,
  });

  final List<Product> products;
  final List<String> categories;
  final String? selectedCategory;

  @override
  List<Object?> get props => [products, categories, selectedCategory];
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
