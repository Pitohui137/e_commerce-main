import 'package:equatable/equatable.dart';

class ShippingAddress extends Equatable {
  const ShippingAddress({
    required this.recipientName,
    required this.phone,
    required this.street,
    required this.city,
    required this.province,
    required this.postalCode,
  });

  final String recipientName;
  final String phone;
  final String street;
  final String city;
  final String province;
  final String postalCode;

  String get fullAddress =>
      '$street, $city, $province $postalCode';

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      recipientName: json['recipient_name'] as String,
      phone: json['phone'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      province: json['province'] as String,
      postalCode: json['postal_code'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'recipient_name': recipientName,
        'phone': phone,
        'street': street,
        'city': city,
        'province': province,
        'postal_code': postalCode,
      };

  @override
  List<Object?> get props =>
      [recipientName, phone, street, city, province, postalCode];
}
