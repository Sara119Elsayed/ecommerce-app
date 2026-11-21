import '../../data/models/cart.dart';
import '../../data/models/product.dart';

class ShopState {
  const ShopState({
    this.products = const [],
    this.categories = const [],
    this.carts = const [],
    this.productsLoading = true,
    this.categoriesLoading = true,
    this.cartsLoading = false,
    this.cartsLoaded = false,
    this.showAllCarts = false,
    this.productError = '',
    this.categoryError = '',
    this.cartError = '',
    this.search = '',
    this.category,
    this.sort = 'recommended',
    this.selectedProduct,
    this.selectedProductLoading = false,
    this.detailError = '',
    this.message = '',
  });

  final List<Product> products;
  final List<String> categories;
  final List<Cart> carts;
  final bool productsLoading;
  final bool categoriesLoading;
  final bool cartsLoading;
  final bool cartsLoaded;
  final bool showAllCarts;
  final String productError;
  final String categoryError;
  final String cartError;
  final String search;
  final String? category;
  final String sort;
  final Product? selectedProduct;
  final bool selectedProductLoading;
  final String detailError;
  final String message;

  ShopState copyWith({
    List<Product>? products,
    List<String>? categories,
    List<Cart>? carts,
    bool? productsLoading,
    bool? categoriesLoading,
    bool? cartsLoading,
    bool? cartsLoaded,
    bool? showAllCarts,
    String? productError,
    String? categoryError,
    String? cartError,
    String? search,
    String? category,
    bool clearCategory = false,
    String? sort,
    Product? selectedProduct,
    bool clearSelectedProduct = false,
    bool? selectedProductLoading,
    String? detailError,
    String? message,
  }) {
    return ShopState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      carts: carts ?? this.carts,
      productsLoading: productsLoading ?? this.productsLoading,
      categoriesLoading: categoriesLoading ?? this.categoriesLoading,
      cartsLoading: cartsLoading ?? this.cartsLoading,
      cartsLoaded: cartsLoaded ?? this.cartsLoaded,
      showAllCarts: showAllCarts ?? this.showAllCarts,
      productError: productError ?? this.productError,
      categoryError: categoryError ?? this.categoryError,
      cartError: cartError ?? this.cartError,
      search: search ?? this.search,
      category: clearCategory ? null : category ?? this.category,
      sort: sort ?? this.sort,
      selectedProduct: clearSelectedProduct
          ? null
          : selectedProduct ?? this.selectedProduct,
      selectedProductLoading:
          selectedProductLoading ?? this.selectedProductLoading,
      detailError: detailError ?? this.detailError,
      message: message ?? this.message,
    );
  }
}
