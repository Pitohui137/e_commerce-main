import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/repositories/product_repository.dart';
import 'insert_product_state.dart';

class InsertProductCubit extends Cubit<InsertProductState> {
  InsertProductCubit(this._repository) : super(const InsertProductIdle());

  final ProductRepository _repository;

  Future<void> submit({
    required String title,
    required String priceText,
    required String description,
    required String image,
    required String category,
  }) async {
    final price = double.tryParse(priceText.trim());
    if (title.trim().isEmpty) {
      emit(const InsertProductFailure('Please enter a title.'));
      return;
    }
    if (price == null || price < 0) {
      emit(const InsertProductFailure('Please enter a valid price.'));
      return;
    }
    if (description.trim().isEmpty) {
      emit(const InsertProductFailure('Please enter a description.'));
      return;
    }
    if (image.trim().isEmpty) {
      emit(const InsertProductFailure('Please enter an image URL.'));
      return;
    }
    if (category.trim().isEmpty) {
      emit(const InsertProductFailure('Please choose or enter a category.'));
      return;
    }

    emit(const InsertProductSubmitting());
    try {
      final product = await _repository.createProduct(
        title: title.trim(),
        price: price,
        description: description.trim(),
        image: image.trim(),
        category: category.trim(),
      );
      emit(InsertProductSuccess(product));
    } on AppException catch (e) {
      emit(InsertProductFailure(e.message));
    } catch (e) {
      emit(InsertProductFailure(e.toString()));
    }
  }

  void reset() => emit(const InsertProductIdle());
}
