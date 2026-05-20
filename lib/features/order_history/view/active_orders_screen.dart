import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../app/app_router.dart';
import '../../../core/widgets/order_status_chip.dart';
import '../../../core/widgets/price_label.dart';
import '../../../data/models/order.dart';
import '../../../data/models/order_status.dart';
import '../viewmodel/active_orders_cubit.dart';
import '../viewmodel/active_orders_state.dart';

class ActiveOrdersScreen extends StatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  State<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ActiveOrdersCubit>().load();
  }

  Future<void> _confirmOrder(BuildContext context, String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Apakah pesanan sudah Anda terima dengan lengkap?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pesanan Diterima'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ActiveOrdersCubit>().confirmReceived(orderId);
      if (!context.mounted) return;
      final state = context.read<ActiveOrdersCubit>().state;
      if (state is ActiveOrdersError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      } else if (state is ActiveOrdersLoaded && state.orders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pesanan dikonfirmasi. Sekarang dapat dilihat di Riwayat Pembelian.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActiveOrdersCubit, ActiveOrdersState>(
      listener: (context, state) {
        if (state is ActiveOrdersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAF9F7),
          title: const Text(
            'Pesanan Aktif',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: BlocBuilder<ActiveOrdersCubit, ActiveOrdersState>(
          builder: (context, state) {
            if (state is ActiveOrdersLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ActiveOrdersError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () =>
                          context.read<ActiveOrdersCubit>().load(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final orders = switch (state) {
              ActiveOrdersLoaded s => s.orders,
              ActiveOrdersConfirming s => s.orders,
              _ => const <Order>[],
            };

            if (orders.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping_outlined,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      const Text(
                        'Tidak ada pesanan aktif',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Semua pesanan sudah diterima atau belum ada checkout.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              );
            }

            final confirmingId = state is ActiveOrdersConfirming
                ? state.confirmingId
                : null;
            final dateFormat = DateFormat('d MMM yyyy, HH:mm', 'id_ID');

            return RefreshIndicator(
              onRefresh: () => context.read<ActiveOrdersCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: Colors.orange[800]),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tekan "Pesanan Diterima" setelah barang sampai. '
                            'Riwayat Pembelian hanya menampilkan pesanan yang sudah dikonfirmasi.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[800],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...orders.map((order) {
                    final shortId = order.id.length > 8
                        ? order.id.substring(0, 8)
                        : order.id;
                    final isConfirming = confirmingId == order.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: const Color(0xFFF0EFED)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Pesanan #$shortId',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const OrderStatusChip(
                                  status: OrderStatus.prosesPengantaran,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateFormat.format(order.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${order.lines.length} item',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                PriceLabel(
                                  order.total,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: isConfirming
                                        ? null
                                        : () {
                                            Navigator.pushNamed(
                                              context,
                                              AppRoutes.orderDetail,
                                              arguments: order.id,
                                            );
                                          },
                                    child: const Text('Detail'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: FilledButton(
                                    onPressed: isConfirming
                                        ? null
                                        : () => _confirmOrder(
                                              context, order.id),
                                    child: isConfirming
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Pesanan Diterima'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
