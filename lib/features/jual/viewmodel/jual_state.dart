import 'package:equatable/equatable.dart';

import '../../../data/models/user_product.dart';

sealed class JualState extends Equatable {
  const JualState();

  @override
  List<Object?> get props => [];
}

class JualInitial extends JualState {
  const JualInitial();
}

class JualLoading extends JualState {
  const JualLoading();
}

class JualLoaded extends JualState {
  const JualLoaded(this.products);

  final List<UserProduct> products;

  @override
  List<Object?> get props => [products];
}

class JualError extends JualState {
  const JualError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class JualActionLoading extends JualState {
  const JualActionLoading(this.products);

  final List<UserProduct> products;

  @override
  List<Object?> get props => [products];
}