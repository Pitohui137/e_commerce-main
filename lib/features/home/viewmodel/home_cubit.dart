import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeInitial());

  final ProductRepository _repository;

  /// Fake Store POST does not add items to GET /products; we merge locally.
  final List<Product> _sessionInserted = [];

  /// Raw API list for the current view (before merging session inserts).
  List<Product> _cachedApiProducts = [];

  List<Product> _merged(List<Product> apiSlice, String? selectedCategory) {
    final sessionPart = selectedCategory == null || selectedCategory.isEmpty
        ? _sessionInserted
        : _sessionInserted
            .where((p) => p.category == selectedCategory)
            .toList();
    final apiIds = apiSlice.map((e) => e.id).toSet();
    final prefix =
        sessionPart.where((p) => !apiIds.contains(p.id)).toList();
    return [...prefix, ...apiSlice];
  }

  Future<void> load() async {
    emit(const HomeLoading());
    try {
      final categories = await _repository.fetchCategories();
      final products = await _repository.fetchProducts();
      _cachedApiProducts = products;
      emit(HomeLoaded(
        products: _merged(products, null),
        categories: categories,
        selectedCategory: null,
      ));
    } on AppException catch (e) {
      emit(HomeError(e.message));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> selectCategory(String? category) async {
    final current = state;
    if (current is! HomeLoaded) return;

    if (category == null || category.isEmpty) {
      emit(const HomeLoading());
      try {
        final products = await _repository.fetchProducts();
        _cachedApiProducts = products;
        emit(HomeLoaded(
          products: _merged(products, null),
          categories: current.categories,
          selectedCategory: null,
        ));
      } on AppException catch (e) {
        emit(HomeError(e.message));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
      return;
    }

    emit(const HomeLoading());
    try {
      final products = await _repository.fetchProductsByCategory(category);
      _cachedApiProducts = products;
      emit(HomeLoaded(
        products: _merged(products, category),
        categories: current.categories,
        selectedCategory: category,
      ));
    } on AppException catch (e) {
      emit(HomeError(e.message));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  /// Call after a successful POST so the item appears despite API not listing it.
  void registerInsertedProduct(Product product) {
    if (!_sessionInserted.any((e) => e.id == product.id)) {
      _sessionInserted.insert(0, product);
    }
    final current = state;
    if (current is! HomeLoaded) return;
    emit(HomeLoaded(
      products: _merged(_cachedApiProducts, current.selectedCategory),
      categories: current.categories,
      selectedCategory: current.selectedCategory,
    ));
  }

  Future<void> retry() => load();
}
