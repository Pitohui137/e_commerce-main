import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/product.dart';
import '../../../data/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._repository) : super(CartState(lines: _repository.lines)) {
    _sync();
  }

  final CartRepository _repository;

  void _sync() {
    emit(CartState(lines: _repository.lines));
  }

  void addProduct(Product product) {
    _repository.addOrIncrement(product);
    _sync();
  }

  void increment(int productId) {
    _repository.increment(productId);
    _sync();
  }

  void decrement(int productId) {
    _repository.decrement(productId);
    _sync();
  }

  void remove(int productId) {
    _repository.remove(productId);
    _sync();
  }

  void clear() {
    _repository.clear();
    _sync();
  }
}
