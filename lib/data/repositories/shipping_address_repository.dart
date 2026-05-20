import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/shipping_address.dart';

const _shippingAddressKey = 'e_commerce_shipping_address_v1';

class ShippingAddressRepository {
  ShippingAddressRepository(this._prefs);

  final SharedPreferences _prefs;

  ShippingAddress? load() {
    final raw = _prefs.getString(_shippingAddressKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return ShippingAddress.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(ShippingAddress address) async {
    await _prefs.setString(
      _shippingAddressKey,
      jsonEncode(address.toJson()),
    );
  }
}
