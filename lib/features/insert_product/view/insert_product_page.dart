import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/models/picked_image.dart';
import '../viewmodel/insert_product_cubit.dart';
import '../viewmodel/insert_product_state.dart';

const _fashionCategories = ['jewelery', "men's clothing", "women's clothing"];

class InsertProductPage extends StatefulWidget {
  const InsertProductPage({super.key});

  @override
  State<InsertProductPage> createState() => _InsertProductPageState();
}

class _InsertProductPageState extends State<InsertProductPage> {
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _category;
  PickedImage? _pickedImage;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image =
          await context.read<InsertProductCubit>().pickImage(source);
      if (image != null) setState(() => _pickedImage = image);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const Text(
              'Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            if (!kIsWeb) ...[
              _SourceTile(
                icon: Icons.camera_alt_outlined,
                label: 'Kamera',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
            ],
            _SourceTile(
              icon: Icons.photo_library_outlined,
              label: 'Galeri',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Jual Produk Baru',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.5,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: BlocConsumer<InsertProductCubit, InsertProductState>(
        listener: (context, state) {
          if (state is InsertProductSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Produk berhasil ditambahkan!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop(state.product);
          } else if (state is InsertProductFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFD32F2F),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<InsertProductCubit>().reset();
            // Restore image file if it was picked before failure
            setState(() {
              _pickedImage = context.read<InsertProductCubit>().pickedImage;
            });
          }
        },
        builder: (context, state) {
          final submitting = state is InsertProductSubmitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Image Picker ───────────────────────────────────
                  _ImagePickerCard(
                    pickedImage: _pickedImage,
                    onTap: submitting ? null : _showImageSourceSheet,
                  ),
                  const SizedBox(height: 20),

                  // ── Title ──────────────────────────────────────────
                  _FormField(
                    controller: _titleCtrl,
                    label: 'Nama Produk',
                    icon: Icons.shopping_bag_outlined,
                    action: TextInputAction.next,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                    enabled: !submitting,
                  ),
                  const SizedBox(height: 14),

                  // ── Price ──────────────────────────────────────────
                  _FormField(
                    controller: _priceCtrl,
                    label: 'Harga (Rp)',
                    icon: Icons.payments_outlined,
                    type: TextInputType.number,
                    action: TextInputAction.next,
                    hint: 'contoh: 150000',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                      if (double.tryParse(v.trim()) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                    enabled: !submitting,
                  ),
                  const SizedBox(height: 14),

                  // ── Category ───────────────────────────────────────
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      prefixIcon: const Icon(
                        Icons.category_outlined,
                        size: 20,
                        color: Color(0xFF888888),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF1A1A1A), width: 1.5),
                      ),
                    ),
                    items: _fashionCategories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                  c[0].toUpperCase() + c.substring(1),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: submitting
                        ? null
                        : (v) => setState(() => _category = v),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Pilih kategori' : null,
                  ),
                  const SizedBox(height: 14),

                  // ── Description ────────────────────────────────────
                  _FormField(
                    controller: _descCtrl,
                    label: 'Deskripsi Produk',
                    icon: Icons.description_outlined,
                    maxLines: 4,
                    action: TextInputAction.done,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                    enabled: !submitting,
                  ),
                  const SizedBox(height: 28),

                  // ── Submit ─────────────────────────────────────────
                  FilledButton(
                    onPressed: submitting
                        ? null
                        : () {
                            if (!_formKey.currentState!.validate()) return;
                            if (_pickedImage == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Pilih foto produk terlebih dahulu'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            context.read<InsertProductCubit>().submit(
                                  title: _titleCtrl.text,
                                  priceText: _priceCtrl.text,
                                  description: _descCtrl.text,
                                  category: _category ?? '',
                                  image: _pickedImage,
                                );
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    child: submitting
                        ? const _LoadingIndicator()
                        : const Text('Upload & Simpan Produk'),
                  ),

                  if (submitting) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Mengupload foto & menyimpan produk...',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Image Picker Card ───────────────────────────────────────────────────────

class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({required this.pickedImage, required this.onTap});

  final PickedImage? pickedImage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = pickedImage != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFE8E8E8),
            width: hasImage ? 1.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(pickedImage!.bytes, fit: BoxFit.cover),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Ganti Foto',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EFED),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined,
                          size: 30, color: Color(0xFF888888)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tap untuk tambah foto',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kamera atau galeri',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[400]),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Source Tile ─────────────────────────────────────────────────────────────

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFFAAAAAA)),
          ],
        ),
      ),
    );
  }
}

// ── Reusable form field ─────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.type = TextInputType.text,
    this.action = TextInputAction.next,
    this.hint,
    this.maxLines = 1,
    this.validator,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType type;
  final TextInputAction action;
  final String? hint;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      textInputAction: action,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            Icon(icon, size: 20, color: const Color(0xFF888888)),
        filled: true,
        fillColor: Colors.white,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 22,
      width: 22,
      child:
          CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}