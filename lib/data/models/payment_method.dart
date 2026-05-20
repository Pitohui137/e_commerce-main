import 'package:flutter/material.dart';

enum PaymentMethodType {
  bankTransfer,
  gopay,
  ovo,
  dana,
  cod,
}

class PaymentMethodOption {
  const PaymentMethodOption({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  final PaymentMethodType type;
  final String label;
  final String subtitle;
  final IconData icon;
}

const kPaymentMethods = [
  PaymentMethodOption(
    type: PaymentMethodType.bankTransfer,
    label: 'Transfer Bank',
    subtitle: 'BCA, Mandiri, BRI',
    icon: Icons.account_balance_outlined,
  ),
  PaymentMethodOption(
    type: PaymentMethodType.gopay,
    label: 'GoPay',
    subtitle: 'E-Wallet Gojek',
    icon: Icons.account_balance_wallet_outlined,
  ),
  PaymentMethodOption(
    type: PaymentMethodType.ovo,
    label: 'OVO',
    subtitle: 'E-Wallet',
    icon: Icons.wallet_outlined,
  ),
  PaymentMethodOption(
    type: PaymentMethodType.dana,
    label: 'DANA',
    subtitle: 'E-Wallet',
    icon: Icons.payments_outlined,
  ),
  PaymentMethodOption(
    type: PaymentMethodType.cod,
    label: 'Bayar di Tempat (COD)',
    subtitle: 'Bayar saat barang diterima',
    icon: Icons.local_shipping_outlined,
  ),
];

String paymentMethodLabel(PaymentMethodType type) {
  return kPaymentMethods
      .firstWhere((m) => m.type == type)
      .label;
}
