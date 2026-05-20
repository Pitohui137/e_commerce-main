import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/user_product.dart';
import '../../../data/repositories/user_product_repository.dart';
import '../../../data/services/image_picker_service.dart';
import 'jual_state.dart';

class JualCubit extends Cubit<JualState> {
  JualCubit({
    required this.repository,
    required this.imageService,
  }) : super(const JualInitial());

  final UserProductRepository repository;
  final ImagePickerService imageService;

  List<UserProduct> get _current {
    final s = state;
    if (s is JualLoaded) return s.products;
    if (s is JualActionLoading) return s.products;
    return [];
  }

  Future<void> load() async {
    emit(const JualLoading());
    try {
      final products = await repository.fetchMine();
      emit(JualLoaded(products));
    } on AppException catch (e) {
      emit(JualError(e.message));
    } catch (e) {
      emit(JualError(e.toString()));
    }
  }

  Future<bool> addProduct({
    required String title,
    required double price,
    required String description,
    required String category,
    required String imageUrl,
  }) async {
    final current = _current;
    emit(JualActionLoading(current));
    try {
      final product = await repository.create(
        title: title,
        price: price,
        description: description,
        category: category,
        imageUrl: imageUrl,
      );
      emit(JualLoaded([product, ...current]));
      return true;
    } on AppException catch (e) {
      emit(JualError(e.message));
      return false;
    } catch (e) {
      emit(JualError(e.toString()));
      return false;
    }
  }

  void prependProduct(UserProduct product) {
    final current = _current;
    final updated = [
      product,
      ...current.where((p) => p.id != product.id),
    ];
    emit(JualLoaded(updated));
  }

  Future<bool> deleteProduct(UserProduct product) async {
    final current = _current;
    emit(JualActionLoading(current));
    try {
      await repository.delete(product.id);
      // Best-effort: delete image from storage
      await imageService.deleteImage(product.imageUrl);
      emit(JualLoaded(current.where((p) => p.id != product.id).toList()));
      return true;
    } on AppException catch (e) {
      emit(JualError(e.message));
      return false;
    } catch (e) {
      emit(JualError(e.toString()));
      return false;
    }
  }
}