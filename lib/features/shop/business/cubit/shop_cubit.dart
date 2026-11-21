import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cart.dart';
import '../../data/models/product.dart';
import '../../data/repositories/shop_repository.dart';
import 'shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  ShopCubit(this._repository) : super(const ShopState());

  final ShopRepository _repository;
  int _productRequest = 0;

  Future<void> loadInitial() async {
    await Future.wait([loadProducts(), loadCategories()]);
  }

  Future<void> loadProducts() async {
    final request = ++_productRequest;
    emit(
      state.copyWith(
        productsLoading: true,
        productError: '',
      ),
    );
    try {
      final sortParts = state.sort.split('-');
      final products = await _repository.getProducts(
        search: state.search,
        category: state.category,
        sortBy: state.sort == 'recommended' ? null : sortParts.first,
        order: sortParts.length > 1 ? sortParts.last : 'asc',
      );
      if (isClosed || request != _productRequest) return;
      emit(state.copyWith(products: products, productsLoading: false));
    } catch (error) {
      if (isClosed || request != _productRequest) return;
      emit(
        state.copyWith(
          productsLoading: false,
          productError: error.toString(),
        ),
      );
    }
  }

  Future<void> loadCategories() async {
    emit(state.copyWith(categoriesLoading: true, categoryError: ''));
    try {
      final categories = await _repository.getCategories();
      if (!isClosed) {
        emit(
          state.copyWith(categories: categories, categoriesLoading: false),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            categoriesLoading: false,
            categoryError: error.toString(),
          ),
        );
      }
    }
  }

  void updateSearch(String value) {
    emit(state.copyWith(search: value.trim()));
    loadProducts();
  }

  void updateCategory(String? value) {
    emit(
      value == null
          ? state.copyWith(clearCategory: true)
          : state.copyWith(category: value),
    );
    loadProducts();
  }

  void updateSort(String value) {
    emit(state.copyWith(sort: value));
    loadProducts();
  }

  Future<void> loadCarts({bool all = false, bool force = false}) async {
    if (state.cartsLoading ||
        (!force && state.cartsLoaded && state.showAllCarts == all)) {
      return;
    }
    emit(
      state.copyWith(
        cartsLoading: true,
        cartError: '',
        showAllCarts: all,
      ),
    );
    try {
      final carts = all
          ? await _repository.getCarts()
          : await _repository.getCartsByUser(5);
      if (!isClosed) {
        emit(
          state.copyWith(
            carts: carts,
            cartsLoading: false,
            cartsLoaded: true,
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            cartsLoading: false,
            cartsLoaded: false,
            cartError: error.toString(),
          ),
        );
      }
    }
  }

  Future<void> addToCart(Product product) async {
    final currentCart = state.showAllCarts || state.carts.isEmpty
        ? null
        : state.carts.first;
    final items = <int, CartItem>{
      if (currentCart != null)
        for (final item in currentCart.products) item.id: item,
    };
    final item = items[product.id];
    items[product.id] = CartItem(
      id: product.id,
      title: product.title,
      price: product.price,
      quantity: (item?.quantity ?? 0) + 1,
      thumbnail: product.thumbnail,
    );

    emit(state.copyWith(cartsLoading: true, cartError: ''));
    try {
      final cart = await _repository.addCart(
        userId: 5,
        products: items.values.toList(),
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            carts: [cart],
            cartsLoading: false,
            cartsLoaded: true,
            showAllCarts: false,
            message: '${product.title} added to cart',
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            cartsLoading: false,
            cartError: error.toString(),
            message: 'Could not add item to cart: $error',
          ),
        );
      }
    }
  }

  Future<Product?> addProduct(Map<String, dynamic> data) async {
    try {
      final product = await _repository.addProduct(data);
      if (isClosed) return null;
      emit(
        state.copyWith(
          products: [product, ...state.products],
          search: '',
          clearCategory: true,
          message: 'Product created',
        ),
      );
      return product;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(message: 'Could not create product: $error'));
      }
      return null;
    }
  }

  Future<void> loadProduct(int id) async {
    emit(
      state.copyWith(
        clearSelectedProduct: true,
        selectedProductLoading: true,
        detailError: '',
      ),
    );
    try {
      final product = await _repository.getProduct(id);
      if (!isClosed) {
        emit(
          state.copyWith(
            selectedProduct: product,
            selectedProductLoading: false,
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            selectedProductLoading: false,
            detailError: error.toString(),
          ),
        );
      }
    }
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final product = await _repository.updateProduct(id, data);
      if (!isClosed) {
        emit(
          state.copyWith(
            selectedProduct: product,
            products: [
              for (final item in state.products)
                if (item.id == product.id) product else item,
            ],
            message: 'Product updated',
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(message: 'Could not update product: $error'));
      }
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _repository.deleteProduct(id);
      if (isClosed) return false;
      emit(
        state.copyWith(
          products: state.products.where((product) => product.id != id).toList(),
          clearSelectedProduct: true,
          message: 'Product deleted',
        ),
      );
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(message: 'Could not delete product: $error'));
      }
      return false;
    }
  }

  void clearMessage() {
    emit(state.copyWith(message: ''));
  }

  @override
  Future<void> close() {
    _repository.close();
    return super.close();
  }
}
