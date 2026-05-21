import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_router.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/product.dart';
import '../../../data/models/user_product.dart';
import '../../cart/viewmodel/cart_cubit.dart';
import '../../cart/viewmodel/cart_state.dart';
import 'home_cubit.dart';
import '../viewmodel/home_state.dart';
import 'product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeBody();
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final state = context.read<HomeCubit>().state;
    if (state is HomeInitial) {
      context.read<HomeCubit>().load();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: const Color(0xFFFAF9F7),
                elevation: 0,
                scrolledUnderElevation: 0,
                toolbarHeight: 60,
                title: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VERNIQUE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: Color(0xFF0F0F0F),
                      ),
                    ),
                    Text(
                      'Temukan koleksi terbaikmu',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Cart button
                  BlocBuilder<CartCubit, CartState>(
                    builder: (context, cartState) {
                      final count = cartState.lines.fold<int>(0, (s, l) => s + l.quantity);
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F0F0F),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
                              if (count > 0)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFC9A84C),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$count',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Add product button
                  GestureDetector(
                    onTap: () async {
                      final created =
                          await Navigator.of(context, rootNavigator: true)
                              .pushNamed<UserProduct?>(
                        AppRoutes.insertProduct,
                      );
                      if (!context.mounted) return;
                      if (created != null) {
                        context.read<HomeCubit>().registerInsertedProduct(
                              created.toDisplayProduct(),
                            );
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: const Icon(Icons.add_rounded, color: Color(0xFF0F0F0F), size: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(52),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Cari produk fashion...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 20),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────────
              if (state is HomeInitial || state is HomeLoading)
                const SliverFillRemaining(child: LoadingView())
              else if (state is HomeError)
                SliverFillRemaining(
                  child: AsyncErrorView(
                    message: state.message,
                    onRetry: () => context.read<HomeCubit>().retry(),
                  ),
                )
              else if (state is HomeLoaded) ...[
                SliverToBoxAdapter(
                  child: _CategoryChips(
                    categories: state.categories,
                    selected: state.selectedCategory,
                    onSelect: (c) =>
                        context.read<HomeCubit>().selectCategory(c),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  sliver: _ProductGrid(
                    products: state.products
                        .where((p) => _searchQuery.isEmpty ||
                            p.title.toLowerCase().contains(_searchQuery))
                        .toList(),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ── Category Chips ──────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  final List<String> categories;
  final String? selected;
  final void Function(String?) onSelect;

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final all = [null, ...categories];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = all[i];
          final isSelected = cat == selected;
          final label = cat == null ? 'Semua' : _cap(cat);
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0F0F0F)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0F0F0F)
                      : const Color(0xFFE8E8E8),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Product Grid ────────────────────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              children: [
                Icon(Icons.search_off_rounded,
                    size: 56, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'Produk tidak ditemukan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.productDetail,
              arguments: product,
            ),
            onAddToCart: () {
              context.read<CartCubit>().addProduct(product);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ditambahkan ke keranjang')),
              );
            },
          );
        },
        childCount: products.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
    );
  }
}