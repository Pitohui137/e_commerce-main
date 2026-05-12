import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/repositories/customer_repository.dart';
import 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  CustomerCubit(this._repository) : super(const CustomerInitial());

  final CustomerRepository _repository;

  Future<void> load() async {
    emit(const CustomerLoading());
    try {
      final customers = await _repository.fetchAll();
      emit(CustomerLoaded(customers));
    } on AppException catch (e) {
      emit(CustomerError(e.message));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<bool> create({
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    final current = _currentList;
    emit(CustomerActionLoading(current));
    try {
      final customer = await _repository.create(
        name: name,
        email: email,
        phone: phone,
        address: address,
      );
      emit(CustomerLoaded([customer, ...current]));
      return true;
    } on AppException catch (e) {
      emit(CustomerError(e.message));
      return false;
    } catch (e) {
      emit(CustomerError(e.toString()));
      return false;
    }
  }

  Future<bool> update({
    required String id,
    required String name,
    required String email,
    String? phone,
    String? address,
  }) async {
    final current = _currentList;
    emit(CustomerActionLoading(current));
    try {
      final updated = await _repository.update(
        id: id,
        name: name,
        email: email,
        phone: phone,
        address: address,
      );
      final list =
          current.map((c) => c.id == id ? updated : c).toList();
      emit(CustomerLoaded(list));
      return true;
    } on AppException catch (e) {
      emit(CustomerError(e.message));
      return false;
    } catch (e) {
      emit(CustomerError(e.toString()));
      return false;
    }
  }

  Future<bool> delete(String id) async {
    final current = _currentList;
    emit(CustomerActionLoading(current));
    try {
      await _repository.delete(id);
      final list = current.where((c) => c.id != id).toList();
      emit(CustomerLoaded(list));
      return true;
    } on AppException catch (e) {
      emit(CustomerError(e.message));
      return false;
    } catch (e) {
      emit(CustomerError(e.toString()));
      return false;
    }
  }

  List get _currentList {
    final s = state;
    if (s is CustomerLoaded) return s.customers;
    if (s is CustomerActionLoading) return s.customers;
    return [];
  }
}