import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/user_product_repository.dart';
import '../viewmodel/home_state.dart';

const _fashionCategories = {'jewelery', "men's clothing", "women's clothing"};

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository, this._userProductRepository)
      : super(const HomeInitial());

  final ProductRepository _repository;
  final UserProductRepository _userProductRepository;

  List<Product> _fashionOnly(List<Product> products) =>
      products.where((p) => _fashionCategories.contains(p.category)).toList();

  Future<void> load() async {
    emit(const HomeLoading());
    try {
      final categories = await _repository.fetchCategories();
      final apiProducts = await _repository.fetchProducts();
      final userProducts = await _userProductRepository.fetchAllForCatalog();

      final fashionCategories =
          categories.where((c) => _fashionCategories.contains(c)).toList();

      final userDisplayProducts =
          userProducts.map((up) => up.toDisplayProduct()).toList();

      final allProducts = <Product>[
        ...userDisplayProducts,
        ..._fashionOnly(apiProducts),
      ];

      emit(HomeLoaded(
        products: allProducts,
        categories: fashionCategories,
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

    emit(const HomeLoading());
    try {
      if (category == null || category.isEmpty) {
        await load();
        return;
      }

      final apiProducts =
          await _repository.fetchProductsByCategory(category);
      final userProducts = await _userProductRepository.fetchAllForCatalog();

      final userDisplayProducts = userProducts
          .where((up) => up.category == category)
          .map((up) => up.toDisplayProduct())
          .toList();

      emit(HomeLoaded(
        products: <Product>[...userDisplayProducts, ...apiProducts],
        categories: current.categories,
        selectedCategory: category,
      ));
    } on AppException catch (e) {
      emit(HomeError(e.message));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  void registerInsertedProduct(Product product) {
    final current = state;
    if (current is! HomeLoaded) return;
    final alreadyExists =
        current.products.any((p) => p.id == product.id);
    if (alreadyExists) return;
    emit(HomeLoaded(
      products: [product, ...current.products],
      categories: current.categories,
      selectedCategory: current.selectedCategory,
    ));
  }

  Future<void> retry() => load();
}