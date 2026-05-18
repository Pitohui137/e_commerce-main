import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/customer.dart';
import '../viewmodel/customer_cubit.dart';
import '../viewmodel/customer_state.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Pelanggan',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
            color: Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => _showForm(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _search = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau email...',
                  hintStyle: TextStyle(
                      color: Colors.grey[400], fontSize: 14),
                  prefixIcon:
                      Icon(Icons.search, color: Colors.grey[400], size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: BlocConsumer<CustomerCubit, CustomerState>(
              listener: (context, state) {
                if (state is CustomerError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: theme.colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  // Reload after error so the list refreshes
                  context.read<CustomerCubit>().load();
                }
              },
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final customers = switch (state) {
                  CustomerLoaded s => s.customers,
                  CustomerActionLoading s => s.customers,
                  _ => <Customer>[],
                };

                final filtered = _search.isEmpty
                    ? customers
                    : customers
                        .where((c) =>
                            c.name.toLowerCase().contains(_search) ||
                            c.email.toLowerCase().contains(_search))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          _search.isEmpty
                              ? 'Belum ada pelanggan'
                              : 'Tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[400],
                          ),
                        ),
                        if (_search.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Tap "+ Tambah" untuk menambahkan pelanggan baru',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[400]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _CustomerCard(
                    customer: filtered[i],
                    isLoading: state is CustomerActionLoading,
                    onEdit: () => _showForm(context, customer: filtered[i]),
                    onDelete: () =>
                        _confirmDelete(context, filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, {Customer? customer}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CustomerCubit>(),
        child: _CustomerFormSheet(customer: customer),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Pelanggan',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Hapus "${customer.name}"? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CustomerCubit>().delete(customer.id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// ── Customer Card ───────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
  });

  final Customer customer;
  final bool isLoading;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF1A1A1A),
      const Color(0xFF8B5CF6),
      const Color(0xFF0D9488),
      const Color(0xFFE11D48),
      const Color(0xFFD97706),
      const Color(0xFF2563EB),
    ];
    final idx = name.isEmpty ? 0 : name.codeUnitAt(0) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final initials = customer.name.trim().isEmpty
        ? '?'
        : customer.name.trim().split(' ').map((w) => w[0]).take(2).join();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EFED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _avatarColor(customer.name),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    customer.email,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (customer.phone != null &&
                      customer.phone!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone!,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: isLoading ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: const Color(0xFF1A1A1A),
                  tooltip: 'Edit',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F5F5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(36, 36),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: isLoading ? null : onDelete,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red[600],
                  tooltip: 'Hapus',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(36, 36),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Customer Form Bottom Sheet ──────────────────────────────────────────────

class _CustomerFormSheet extends StatefulWidget {
  const _CustomerFormSheet({this.customer});

  final Customer? customer;

  @override
  State<_CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends State<_CustomerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  bool _submitting = false;

  bool get _isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.customer?.name ?? '');
    _emailCtrl =
        TextEditingController(text: widget.customer?.email ?? '');
    _phoneCtrl =
        TextEditingController(text: widget.customer?.phone ?? '');
    _addressCtrl =
        TextEditingController(text: widget.customer?.address ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    bool ok;
    if (_isEdit) {
      ok = await context.read<CustomerCubit>().update(
            id: widget.customer!.id,
            name: _nameCtrl.text,
            email: _emailCtrl.text,
            phone: _phoneCtrl.text,
            address: _addressCtrl.text,
          );
    } else {
      ok = await context.read<CustomerCubit>().create(
            name: _nameCtrl.text,
            email: _emailCtrl.text,
            phone: _phoneCtrl.text,
            address: _addressCtrl.text,
          );
    }
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEdit ? 'Pelanggan diperbarui' : 'Pelanggan ditambahkan'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            _isEdit ? 'Edit Pelanggan' : 'Pelanggan Baru',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(
              children: [
                _field(
                  controller: _nameCtrl,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  action: TextInputAction.next,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _emailCtrl,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  type: TextInputType.emailAddress,
                  action: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Email wajib diisi';
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _phoneCtrl,
                  label: 'Nomor Telepon (opsional)',
                  icon: Icons.phone_outlined,
                  type: TextInputType.phone,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                _field(
                  controller: _addressCtrl,
                  label: 'Alamat (opsional)',
                  icon: Icons.location_on_outlined,
                  action: TextInputAction.done,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15),
            ),
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Pelanggan'),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      textInputAction: action,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
        ),
      ),
    );
  }
}