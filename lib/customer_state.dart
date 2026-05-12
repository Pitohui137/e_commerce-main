import 'package:equatable/equatable.dart';

import '../../../data/models/customer.dart';

sealed class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {
  const CustomerInitial();
}

class CustomerLoading extends CustomerState {
  const CustomerLoading();
}

class CustomerLoaded extends CustomerState {
  const CustomerLoaded(this.customers);
  final List<Customer> customers;

  @override
  List<Object?> get props => [customers];
}

class CustomerError extends CustomerState {
  const CustomerError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class CustomerActionLoading extends CustomerState {
  const CustomerActionLoading(this.customers);
  final List<Customer> customers;

  @override
  List<Object?> get props => [customers];
}