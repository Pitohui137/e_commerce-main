import 'package:equatable/equatable.dart';

import '../../../data/models/product.dart';

sealed class InsertProductState extends Equatable {
  const InsertProductState();

  @override
  List<Object?> get props => [];
}

class InsertProductIdle extends InsertProductState {
  const InsertProductIdle();
}

class InsertProductSubmitting extends InsertProductState {
  const InsertProductSubmitting();
}

class InsertProductSuccess extends InsertProductState {
  const InsertProductSuccess(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

class InsertProductFailure extends InsertProductState {
  const InsertProductFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
