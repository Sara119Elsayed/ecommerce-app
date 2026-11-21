import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business/cubit/shop_cubit.dart';
import '../../business/cubit/shop_state.dart';
import '../../data/models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShopCubit>().loadProduct(widget.product.id);
  }

  Future<void> _edit(Product product) async {
    final draft = await showDialog<ProductDraft>(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );
    if (draft != null && mounted) {
      await context.read<ShopCubit>().updateProduct(product.id, draft.toJson());
    }
  }

  Future<void> _delete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Remove "${product.title}" from the catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final deleted = await context.read<ShopCubit>().deleteProduct(product.id);
    if (deleted && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCubit, ShopState>(
      builder: (context, state) {
        final product = state.selectedProduct;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Product details'),
            actions: [
              if (product != null)
                PopupMenuButton<String>(
                  onSelected: (action) => action == 'edit'
                      ? _edit(product)
                      : _delete(product),
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
            ],
          ),
          body: _buildDetails(context, state, product),
        );
      },
    );
  }

  Widget _buildDetails(
    BuildContext context,
    ShopState state,
    Product? product,
  ) {
    if (state.selectedProductLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.detailError.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.detailError, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    context.read<ShopCubit>().loadProduct(widget.product.id),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }
    if (product == null) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (product.thumbnail.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 1.1,
              child: ProductImage(url: product.thumbnail),
            ),
          ),
        const SizedBox(height: 20),
        Text(
          product.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(product.description),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          children: [
            Chip(label: Text(product.category)),
            Chip(label: Text('Rating ${product.rating.toStringAsFixed(1)}')),
            Chip(label: Text('${product.stock} in stock')),
          ],
        ),
      ],
    );
  }
}
