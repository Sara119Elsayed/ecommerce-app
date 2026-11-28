import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business/cubit/shop_cubit.dart';
import '../../business/cubit/shop_state.dart';
import '../../data/models/cart.dart';
import '../../data/models/product.dart';
import '../../../profile/business/cubit/profile_cubit.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';
import 'product_details_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, this.userId = 5});

  final int userId;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _searchController = TextEditingController();
  int _tabIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createProduct() async {
    final draft = await showDialog<ProductDraft>(
      context: context,
      builder: (context) => const ProductFormDialog(),
    );
    if (draft == null || !mounted) return;
    final product = await context.read<ShopCubit>().addProduct(draft.toJson());
    if (product != null && mounted) _searchController.clear();
  }

  Future<void> _openProduct(Product product) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopCubit, ShopState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        if (state.message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<ShopCubit>().clearMessage();
        }
      },
      builder: (context, state) {
        final showingCart = _tabIndex == 1;
        final showingProfile = _tabIndex == 2;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              showingCart
                  ? 'Your cart'
                  : showingProfile
                  ? 'Your profile'
                  : 'Everyday Shop',
            ),
            actions: [
              if (showingCart)
                PopupMenuButton<String>(
                  tooltip: 'Choose carts',
                  onSelected: (value) => context.read<ShopCubit>().loadCarts(
                    all: value == 'all',
                    force: true,
                  ),
                  itemBuilder: (context) => [
                    CheckedPopupMenuItem(
                      value: 'user',
                      checked: !state.showAllCarts,
                      child: const Text('User 5 carts'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'all',
                      checked: state.showAllCarts,
                      child: const Text('All carts'),
                    ),
                  ],
                ),
              if (!showingCart)
                IconButton(
                  tooltip: showingProfile
                      ? 'Refresh profile'
                      : 'Refresh products',
                  onPressed: () {
                    if (showingProfile) {
                      context.read<ProfileCubit>().loadProfile(widget.userId);
                    } else {
                      context.read<ShopCubit>().loadProducts();
                    }
                  },
                  icon: const Icon(Icons.refresh),
                ),
            ],
          ),
          body: IndexedStack(
            index: _tabIndex,
            children: [
              _buildProductsTab(context, state),
              _buildCartTab(context, state),
              ProfileScreen(userId: widget.userId),
            ],
          ),
          floatingActionButton: showingCart || showingProfile
              ? null
              : FloatingActionButton.extended(
                  onPressed: _createProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Add product'),
                ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tabIndex,
            onDestinationSelected: (index) {
              setState(() => _tabIndex = index);
              if (index == 1) context.read<ShopCubit>().loadCarts();
              if (index == 2) {
                context.read<ProfileCubit>().loadProfile(widget.userId);
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront),
                label: 'Shop',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: 'Cart',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductsTab(BuildContext context, ShopState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) =>
                      context.read<ShopCubit>().updateSearch(value),
                  decoration: InputDecoration(
                    hintText: 'Search products',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        context.read<ShopCubit>().updateSearch('');
                      },
                      icon: const Icon(Icons.close),
                    ),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Search',
                onPressed: () => context.read<ShopCubit>().updateSearch(
                  _searchController.text,
                ),
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: state.category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All categories'),
                    ),
                    ...state.categories.map(
                      (category) => DropdownMenuItem<String?>(
                        value: category,
                        child: Text(_pretty(category)),
                      ),
                    ),
                  ],
                  onChanged: state.categoriesLoading
                      ? null
                      : context.read<ShopCubit>().updateCategory,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: state.sort,
                  decoration: const InputDecoration(
                    labelText: 'Sort',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'recommended',
                      child: Text('Recommended'),
                    ),
                    DropdownMenuItem(
                      value: 'title-asc',
                      child: Text('Title A-Z'),
                    ),
                    DropdownMenuItem(
                      value: 'price-asc',
                      child: Text('Price low'),
                    ),
                    DropdownMenuItem(
                      value: 'price-desc',
                      child: Text('Price high'),
                    ),
                  ],
                  onChanged: (sort) {
                    if (sort != null) context.read<ShopCubit>().updateSort(sort);
                  },
                ),
              ),
            ],
          ),
        ),
        if (state.categoryError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Categories unavailable: ${state.categoryError}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        Expanded(child: _buildProductResults(context, state)),
      ],
    );
  }

  Widget _buildProductResults(BuildContext context, ShopState state) {
    if (state.productsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.productError.isNotEmpty) {
      return _MessageState(
        icon: Icons.cloud_off_outlined,
        message: state.productError,
        actionLabel: 'Try again',
        onAction: () => context.read<ShopCubit>().loadProducts(),
      );
    }
    if (state.products.isEmpty) {
      return _MessageState(
        icon: Icons.search_off,
        message: 'No products found. Try another search or category.',
        actionLabel: 'Clear filters',
        onAction: () {
          _searchController.clear();
          context.read<ShopCubit>().updateSearch('');
          context.read<ShopCubit>().updateCategory(null);
        },
      );
    }
    return RefreshIndicator(
      onRefresh: context.read<ShopCubit>().loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.63,
        ),
        itemCount: state.products.length,
        itemBuilder: (context, index) {
          final product = state.products[index];
          return ProductCard(
            product: product,
            onTap: () => _openProduct(product),
            onAdd: () => context.read<ShopCubit>().addToCart(product),
          );
        },
      ),
    );
  }

  Widget _buildCartTab(BuildContext context, ShopState state) {
    if (state.cartsLoading && state.carts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.cartError.isNotEmpty) {
      return _MessageState(
        icon: Icons.cloud_off_outlined,
        message: state.cartError,
        actionLabel: 'Try again',
        onAction: () => context.read<ShopCubit>().loadCarts(
          force: true,
          all: state.showAllCarts,
        ),
      );
    }
    if (state.carts.isEmpty) {
      return _MessageState(
        icon: Icons.shopping_bag_outlined,
        message: 'Your cart is empty.',
        actionLabel: 'Load user 5 carts',
        onAction: () =>
            context.read<ShopCubit>().loadCarts(force: true, all: false),
      );
    }
    final carts = state.showAllCarts ? state.carts : [state.carts.first];
    final items = carts.expand((cart) => cart.products).toList();
    if (items.isEmpty) {
      return _MessageState(
        icon: Icons.shopping_bag_outlined,
        message: 'No items in the selected cart.',
        actionLabel: 'Refresh carts',
        onAction: () => context.read<ShopCubit>().loadCarts(
          force: true,
          all: state.showAllCarts,
        ),
      );
    }
    final total = items.fold<double>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
    return RefreshIndicator(
      onRefresh: () => context.read<ShopCubit>().loadCarts(
        force: true,
        all: state.showAllCarts,
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.showAllCarts)
            ...carts.map(
              (cart) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Cart ${cart.id} · User ${cart.userId}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ...items.map(_buildCartItem),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ProductImage(url: item.thumbnail, size: 62),
        title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('${item.quantity} × \$${item.price.toStringAsFixed(2)}'),
        trailing: Text(
          '\$${(item.quantity * item.price).toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _pretty(String value) => value
      .split('-')
      .map(
        (word) =>
            word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
