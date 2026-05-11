import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_router.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/product.dart';
import '../../cart/viewmodel/cart_cubit.dart';
import '../../cart/viewmodel/cart_state.dart';
import '../viewmodel/home_cubit.dart';
import '../viewmodel/home_state.dart';
import 'product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _maxContentWidth = 1200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final count = state.lines.fold<int>(
                0,
                (s, line) => s + line.quantity,
              );
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  tooltip: 'Cart',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.cart);
                  },
                  icon: Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return switch (state) {
            HomeInitial() => const LoadingView(),
            HomeLoading() => const LoadingView(message: 'Loading products…'),
            HomeError(:final message) => AsyncErrorView(
                message: message,
                onRetry: () => context.read<HomeCubit>().retry(),
              ),
            HomeLoaded(
              :final products,
              :final categories,
              :final selectedCategory,
            ) =>
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: _maxContentWidth),
                        child: Row(
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: () async {
                                final created =
                                    await Navigator.pushNamed<Product?>(
                                  context,
                                  AppRoutes.insertProduct,
                                );
                                if (!context.mounted) return;
                                if (created != null) {
                                  context
                                      .read<HomeCubit>()
                                      .registerInsertedProduct(created);
                                }
                              },
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('New product'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: _maxContentWidth),
                        child: DropdownButtonFormField<String?>(
                          key: ValueKey<String?>(selectedCategory),
                          initialValue: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All products'),
                            ),
                            ...categories.map(
                              (c) => DropdownMenuItem<String?>(
                                value: c,
                                child: Text(
                                  c,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (c) =>
                              context.read<HomeCubit>().selectCategory(c),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _ProductGrid(
                      products: products,
                    ),
                  ),
                ],
              ),
          };
        },
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No products in this category.',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 900
            ? 4
            : width >= 600
                ? 3
                : 2;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.productDetail,
                      arguments: product,
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
