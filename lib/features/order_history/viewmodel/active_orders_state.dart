import 'package:equatable/equatable.dart';

import '../../../data/models/order.dart';

sealed class ActiveOrdersState extends Equatable {
  const ActiveOrdersState();

  @override
  List<Object?> get props => [];
}

class ActiveOrdersInitial extends ActiveOrdersState {
  const ActiveOrdersInitial();
}

class ActiveOrdersLoading extends ActiveOrdersState {
  const ActiveOrdersLoading();
}

class ActiveOrdersLoaded extends ActiveOrdersState {
  const ActiveOrdersLoaded(this.orders);

  final List<Order> orders;

  @override
  List<Object?> get props => [orders];
}

class ActiveOrdersError extends ActiveOrdersState {
  const ActiveOrdersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ActiveOrdersConfirming extends ActiveOrdersState {
  const ActiveOrdersConfirming(this.orders, this.confirmingId);

  final List<Order> orders;
  final String confirmingId;

  @override
  List<Object?> get props => [orders, confirmingId];
}
