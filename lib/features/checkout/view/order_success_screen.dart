import 'package:flutter/material.dart';

import '../../../app/app_router.dart';
import '../../../core/widgets/order_status_chip.dart';
import '../../../core/widgets/price_label.dart';
import '../../../data/models/order.dart';
import '../../../data/models/order_status.dart';
import '../../../data/models/payment_method.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(44),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 52,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pesanan Berhasil!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pesanan berhasil dibuat. Konfirmasi "Pesanan Diterima" '
                'setelah barang sampai untuk masuk Riwayat Pembelian.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              const OrderStatusChip(status: OrderStatus.prosesPengantaran),
              const SizedBox(height: 32),
              _InfoCard(
                children: [
                  _InfoRow(
                    label: 'No. Pesanan',
                    value: '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    label: 'Total Bayar',
                    valueWidget: PriceLabel(
                      order.total,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    label: 'Pembayaran',
                    value: paymentMethodLabel(order.paymentMethod),
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    label: 'Alamat',
                    value: order.address.fullAddress,
                    maxLines: 3,
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.activeOrders);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1A1A),
                    side: const BorderSide(color: Color(0xFFE8E8E8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Ke Pesanan Aktif'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EFED)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.maxLines = 1,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          flex: 3,
          child: valueWidget ??
              Text(
                value ?? '',
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
        ),
      ],
    );
  }
}
