import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/price_label.dart';
import '../../../data/models/shipping_address.dart';
import '../../../data/models/payment_method.dart';
import '../../../data/repositories/auth_repository.dart';
import '../viewmodel/checkout_cubit.dart';
import '../viewmodel/checkout_state.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final saved = context.read<CheckoutCubit>().state.savedAddress;
    _applyAddress(saved);
    final email = context.read<AuthRepository>().currentUser?.email;
    if (email != null && _nameCtrl.text.isEmpty) {
      _nameCtrl.text = email.split('@').first;
    }
  }

  void _applyAddress(ShippingAddress? saved) {
    if (saved == null) return;
    _nameCtrl.text = saved.recipientName;
    _phoneCtrl.text = saved.phone;
    _streetCtrl.text = saved.street;
    _cityCtrl.text = saved.city;
    _provinceCtrl.text = saved.province;
    _postalCtrl.text = saved.postalCode;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _provinceCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CheckoutCubit>().placeOrder(
          recipientName: _nameCtrl.text,
          phone: _phoneCtrl.text,
          street: _streetCtrl.text,
          city: _cityCtrl.text,
          province: _provinceCtrl.text,
          postalCode: _postalCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutCubit, CheckoutState>(
      listenWhen: (prev, curr) =>
          prev.savedAddress != curr.savedAddress ||
          curr.status == CheckoutStatus.success ||
          curr.status == CheckoutStatus.failure,
      listener: (context, state) {
        if (state.savedAddress != null &&
            _nameCtrl.text.isEmpty &&
            state.status == CheckoutStatus.idle) {
          _applyAddress(state.savedAddress);
        }
        if (state.status == CheckoutStatus.success &&
            state.completedOrder != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  OrderSuccessScreen(order: state.completedOrder!),
            ),
          );
        }
        if (state.status == CheckoutStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<CheckoutCubit>().resetStatus();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAF9F7),
          title: const Text(
            'Checkout',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: BlocBuilder<CheckoutCubit, CheckoutState>(
          builder: (context, state) {
            if (state.lines.isEmpty && state.status != CheckoutStatus.success) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    const Text(
                      'Tidak ada item untuk checkout',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        _SectionHeader(
                          icon: Icons.receipt_long_outlined,
                          title: 'Ringkasan Pesanan',
                        ),
                        const SizedBox(height: 10),
                        _OrderSummaryCard(state: state),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          icon: Icons.location_on_outlined,
                          title: 'Alamat Pengiriman',
                        ),
                        const SizedBox(height: 10),
                        _AddressCard(
                          nameCtrl: _nameCtrl,
                          phoneCtrl: _phoneCtrl,
                          streetCtrl: _streetCtrl,
                          cityCtrl: _cityCtrl,
                          provinceCtrl: _provinceCtrl,
                          postalCtrl: _postalCtrl,
                        ),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          icon: Icons.payment_outlined,
                          title: 'Metode Pembayaran',
                        ),
                        const SizedBox(height: 10),
                        ...kPaymentMethods.map(
                          (method) => _PaymentTile(
                            method: method,
                            selected: state.selectedPayment == method.type,
                            onTap: () => context
                                .read<CheckoutCubit>()
                                .selectPayment(method.type),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _CheckoutBottomBar(
                  total: state.total,
                  isSubmitting: state.isSubmitting,
                  onSubmit: _submit,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.state});

  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EFED)),
      ),
      child: Column(
        children: [
          ...state.lines.map((line) {
            final p = line.product;
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: ColoredBox(
                        color: const Color(0xFFF2F1EF),
                        child: CachedNetworkImage(
                          imageUrl: p.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Qty: ${line.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PriceLabel(
                    line.lineTotal,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Divider(height: 1),
          ),
          _SummaryRow(label: 'Subtotal', amount: state.subtotal),
          _SummaryRow(label: 'Ongkir', amount: state.shippingFee),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                PriceLabel(
                  state.total,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          PriceLabel(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.streetCtrl,
    required this.cityCtrl,
    required this.provinceCtrl,
    required this.postalCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController streetCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController provinceCtrl;
  final TextEditingController postalCtrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EFED)),
      ),
      child: Column(
        children: [
          _CheckoutField(
            controller: nameCtrl,
            label: 'Nama Penerima',
            icon: Icons.person_outline,
            validator: _required,
          ),
          const SizedBox(height: 12),
          _CheckoutField(
            controller: phoneCtrl,
            label: 'No. Telepon',
            icon: Icons.phone_outlined,
            type: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Wajib diisi';
              if (v.trim().length < 10) return 'Nomor telepon tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _CheckoutField(
            controller: streetCtrl,
            label: 'Alamat Lengkap',
            icon: Icons.home_outlined,
            maxLines: 2,
            validator: _required,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CheckoutField(
                  controller: cityCtrl,
                  label: 'Kota/Kab.',
                  icon: Icons.location_city_outlined,
                  validator: _required,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CheckoutField(
                  controller: postalCtrl,
                  label: 'Kode Pos',
                  icon: Icons.markunread_mailbox_outlined,
                  type: TextInputType.number,
                  validator: _required,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CheckoutField(
            controller: provinceCtrl,
            label: 'Provinsi',
            icon: Icons.map_outlined,
            validator: _required,
          ),
        ],
      ),
    );
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'Wajib diisi' : null;
}

class _CheckoutField extends StatelessWidget {
  const _CheckoutField({
    required this.controller,
    required this.label,
    required this.icon,
    this.type = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType type;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF888888)),
        filled: true,
        fillColor: const Color(0xFFFAF9F7),
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
          borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethodOption method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFF0EFED),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFFF2F1EF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    method.icon,
                    color: selected ? Colors.white : const Color(0xFF666666),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        method.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFCCCCCC),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  const _CheckoutBottomBar({
    required this.total,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final double total;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  PriceLabel(
                    total,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  child: isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Bayar Sekarang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
