import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_router.dart';
import '../../../data/repositories/order_repository.dart';
import '../../auth/viewmodel/auth_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.email});

  final String email;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingCount();
  }

  Future<void> _loadPendingCount() async {
    try {
      final pending =
          await context.read<OrderRepository>().fetchInDelivery();
      if (mounted) setState(() => _pendingCount = pending.length);
    } catch (_) {}
  }

  Future<void> _openOrderHistory(BuildContext context) async {
    final hasPending =
        await context.read<OrderRepository>().hasPendingDelivery();
    if (!context.mounted) return;

    if (hasPending) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Konfirmasi pesanan dulu',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Masih ada pesanan berstatus Proses pengantaran. '
            'Tekan "Pesanan Diterima" di Pesanan Aktif sebelum membuka Riwayat Pembelian.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.activeOrders)
                    .then((_) => _loadPendingCount());
              },
              child: const Text('Ke Pesanan Aktif'),
            ),
          ],
        ),
      );
      return;
    }

    await Navigator.pushNamed(context, AppRoutes.orderHistory);
    _loadPendingCount();
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.email.isEmpty
        ? '?'
        : widget.email[0].toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar + email
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F0F0F),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EFE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Akun Aktif',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC9A84C),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Info card
          _InfoCard(
            items: [
              _InfoRow(
                icon: Icons.alternate_email_rounded,
                label: 'Email',
                value: widget.email,
              ),
              _InfoRow(
                icon: Icons.shield_outlined,
                label: 'Provider',
                value: 'Email / Password',
              ),
            ],
          ),

          const SizedBox(height: 16),

          _ActionCard(
            items: [
              _ActionRow(
                icon: Icons.local_shipping_outlined,
                label: 'Pesanan Aktif',
                subtitle: _pendingCount > 0
                    ? '$_pendingCount pesanan · Proses pengantaran'
                    : 'Konfirmasi pesanan yang sedang dikirim',
                badge: _pendingCount > 0 ? '$_pendingCount' : null,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.activeOrders)
                      .then((_) => _loadPendingCount());
                },
              ),
              _ActionRow(
                icon: Icons.receipt_long_outlined,
                label: 'Riwayat Pembelian',
                subtitle: 'Pesanan yang sudah dikonfirmasi diterima',
                onTap: () => _openOrderHistory(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Settings card
          _InfoCard(
            items: [
              _InfoRow(
                icon: Icons.notifications_outlined,
                label: 'Notifikasi',
                value: 'Aktif',
              ),
              _InfoRow(
                icon: Icons.language_outlined,
                label: 'Bahasa',
                value: 'Indonesia',
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Sign out
          OutlinedButton.icon(
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Keluar dari Akun'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD32F2F),
              side: const BorderSide(color: Color(0xFFD32F2F)),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),

          const SizedBox(height: 24),

          // App version
          Center(
            child: Text(
              'Vernique v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Kamu akan keluar dari akun. Kamu bisa masuk lagi kapan saja.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().signOut();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.items});
  final List<_InfoRow> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EFED)),
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map((e) => Column(
                  children: [
                    e.value,
                    if (e.key < items.length - 1)
                      const Divider(height: 1, indent: 52),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF555555)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF999999))),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.items});

  final List<_ActionRow> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EFED)),
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map((e) => Column(
                  children: [
                    e.value,
                    if (e.key < items.length - 1)
                      const Divider(height: 1, indent: 52),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF555555)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE65100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.chevron_right,
                  size: 20, color: Color(0xFFCCCCCC)),
            ],
          ),
        ),
      ),
    );
  }
}