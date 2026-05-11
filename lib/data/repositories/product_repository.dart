import '../models/product.dart';
import '../services/fake_store_api_client.dart';

class ProductRepository {
  ProductRepository(this._client);

  final FakeStoreApiClient _client;

  Future<List<Product>> fetchProducts() async {
    final raw = await _client.getProducts();
    return raw.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<String>> fetchCategories() async {
    final raw = await _client.getCategories();
    return raw.map((e) => e as String).toList();
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    final raw = await _client.getProductsByCategory(category);
    return raw.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Product> fetchProductById(int id) async {
    final map = await _client.getProduct(id);
    return Product.fromJson(map);
  }

  Future<Product> createProduct({
    required String title,
    required double price,
    required String description,
    required String image,
    required String category,
  }) async {
    final map = await _client.createProduct({
      'title': title,
      'price': price,
      'description': description,
      'image': image,
      'category': category,
    });
    return Product.fromJson(map);
  }
}
