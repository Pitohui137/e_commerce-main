import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_router.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../data/models/user_product.dart';
import '../../home/view/home_cubit.dart';
import '../viewmodel/jual_cubit.dart';
import '../viewmodel/jual_state.dart';

class JualScreen extends StatefulWidget {
  const JualScreen({super.key});

  @override
  State<JualScreen> createState() => _JualScreenState();
}

class _JualScreenState extends State<JualScreen> {
  @override
  void initState() {
    super.initState();
    context.read<JualCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JualCubit, JualState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9F7),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFAF9F7),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Produk Jualku',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.5,
                color: Color(0xFF1A1A1A),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: FilledButton.icon(
                  onPressed: state is JualActionLoading
                      ? null
                      : () => _addProduct(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Jual'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          body: switch (state) {
            JualInitial() || JualLoading() => const LoadingView(),
            JualError(:final message) => AsyncErrorView(
                message: message,
                onRetry: () => context.read<JualCubit>().load(),
              ),
            JualLoaded(:final products) ||
            JualActionLoading(:final products) =>
              products.isEmpty
                  ? _EmptyState(
                      onTap: state is JualActionLoading
                          ? null
                          : () => _addProduct(context),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _ProductTile(
                        product: products[i],
                        onDelete: state is JualActionLoading
                            ? null
                            : () => context
                                .read<JualCubit>()
                                .deleteProduct(products[i]),
                      ),
                    ),
          },
        );
      },
    );
  }

  Future<void> _addProduct(BuildContext context) async {
    final created = await Navigator.of(context, rootNavigator: true)
        .pushNamed<UserProduct?>(AppRoutes.insertProduct);
    if (!context.mounted || created == null) return;
    context.read<JualCubit>().prependProduct(created);
    context
        .read<HomeCubit>()
        .registerInsertedProduct(created.toDisplayProduct());
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFED),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.storefront_outlined,
                size: 40, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada produk dijual',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap "+ Jual" untuk mulai berjualan',
            style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Produk'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onDelete});
  final UserProduct product;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: ColoredBox(
                  color: const Color(0xFFF5F5F5),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFFAAAAAA)),
                    ),
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
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F0F0F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EFED),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red[600],
              style: IconButton.styleFrom(
                backgroundColor: Colors.red[50],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(36, 36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
