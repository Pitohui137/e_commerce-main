import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_line.dart';
import '../models/product.dart';

const _cartStorageKey = 'e_commerce_cart_lines_v1';

class CartRepository {
  CartRepository(this._prefs) {
    _loadFromPrefs();
  }

  final SharedPreferences _prefs;
  final List<CartLine> _lines = [];

  List<CartLine> get lines => List.unmodifiable(_lines);

  double get grandTotal =>
      _lines.fold(0.0, (sum, line) => sum + line.lineTotal);

  int get totalItemCount => _lines.fold(0, (sum, line) => sum + line.quantity);

  void _loadFromPrefs() {
    final raw = _prefs.getString(_cartStorageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _lines.clear();
      for (final e in list) {
        _lines.add(CartLine.fromJson(e as Map<String, dynamic>));
      }
    } catch (_) {
      _lines.clear();
    }
  }

  void _persist() {
    final encoded =
        jsonEncode(_lines.map((e) => e.toJson()).toList(growable: false));
    _prefs.setString(_cartStorageKey, encoded);
  }

  void addOrIncrement(Product product) {
    final i = _lines.indexWhere((l) => l.product.id == product.id);
    if (i >= 0) {
      final line = _lines[i];
      _lines[i] = line.copyWith(quantity: line.quantity + 1);
    } else {
      _lines.add(CartLine(product: product, quantity: 1));
    }
    _persist();
  }

  void increment(int productId) {
    final i = _lines.indexWhere((l) => l.product.id == productId);
    if (i < 0) return;
    final line = _lines[i];
    _lines[i] = line.copyWith(quantity: line.quantity + 1);
    _persist();
  }

  void decrement(int productId) {
    final i = _lines.indexWhere((l) => l.product.id == productId);
    if (i < 0) return;
    final line = _lines[i];
    if (line.quantity <= 1) {
      _lines.removeAt(i);
    } else {
      _lines[i] = line.copyWith(quantity: line.quantity - 1);
    }
    _persist();
  }

  void remove(int productId) {
    _lines.removeWhere((l) => l.product.id == productId);
    _persist();
  }

  void clear() {
    _lines.clear();
    _persist();
  }
}
