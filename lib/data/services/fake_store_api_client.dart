import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';

class FakeStoreApiClient {
  FakeStoreApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                headers: {'Content-Type': 'application/json'},
              ),
            );

  final Dio _dio;

  Future<List<dynamic>> getProducts() async {
    try {
      final response = await _dio.get<List<dynamic>>('/products');
      return response.data ?? [];
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _dio.get<List<dynamic>>('/products/categories');
      return response.data ?? [];
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<List<dynamic>> getProductsByCategory(String category) async {
    try {
      final encoded = Uri.encodeComponent(category);
      final response =
          await _dio.get<List<dynamic>>('/products/category/$encoded');
      return response.data ?? [];
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/products/$id');
      final data = response.data;
      if (data == null) {
        throw const AppException('Product not found.');
      }
      return data;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> body) async {
    try {
      final response =
          await _dio.post<Map<String, dynamic>>('/products', data: body);
      final data = response.data;
      if (data == null) {
        throw const AppException('Invalid response from server.');
      }
      return data;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}
