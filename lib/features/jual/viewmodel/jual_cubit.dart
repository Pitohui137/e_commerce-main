import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/product.dart';
import 'jual_state.dart';

class JualCubit extends Cubit<JualState> {
  JualCubit() : super(const JualLoaded([]));

  List<Product> get _current => (state as JualLoaded).products;

  void addProduct(Product product) {
    if (_current.any((p) => p.id == product.id)) return;
    emit(JualLoaded([product, ..._current]));
  }

  void removeProduct(int id) {
    emit(JualLoaded(_current.where((p) => p.id != id).toList()));
  }
}