import '../models/cart.dart';
import '../models/product.dart';
import '../webservices/dummy_json_webservice.dart';

abstract interface class ShopRepository {
  Future<List<Product>> getProducts({
    String? search,
    String? category,
    String? sortBy,
    String order = 'asc',
  });
  Future<List<String>> getCategories();
  Future<Product> getProduct(int id);
  Future<Product> addProduct(Map<String, dynamic> product);
  Future<Product> updateProduct(int id, Map<String, dynamic> updates);
  Future<void> deleteProduct(int id);
  Future<List<Cart>> getCarts();
  Future<List<Cart>> getCartsByUser(int userId);
  Future<Cart> addCart({required int userId, required List<CartItem> products});
  void close();
}

class DummyJsonShopRepository implements ShopRepository {
  DummyJsonShopRepository(this._webService);

  final DummyJsonWebService _webService;

  @override
  Future<List<Product>> getProducts({
    String? search,
    String? category,
    String? sortBy,
    String order = 'asc',
  }) async {
    final data = _asObject(
      await _webService.getProducts(
        search: search,
        category: category,
        sortBy: sortBy,
        order: order,
      ),
    );
    final products = data['products'];
    if (products is! List) {
      throw const FormatException('The products response is invalid.');
    }
    return products
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final data = await _webService.getCategories();
    final categories = data is List
        ? data
        : data is Map<String, dynamic>
        ? data['categories']
        : null;
    if (categories is! List) {
      throw const FormatException('The categories response is invalid.');
    }
    return categories
        .map((category) {
          if (category is Map<String, dynamic>) {
            return category['slug']?.toString() ??
                category['name']?.toString() ??
                '';
          }
          return category.toString();
        })
        .where((category) => category.isNotEmpty)
        .toList();
  }

  @override
  Future<Product> getProduct(int id) async =>
      Product.fromJson(_asObject(await _webService.getProduct(id)));

  @override
  Future<Product> addProduct(Map<String, dynamic> product) async =>
      Product.fromJson(_asObject(await _webService.addProduct(product)));

  @override
  Future<Product> updateProduct(
    int id,
    Map<String, dynamic> updates,
  ) async => Product.fromJson(
    _asObject(await _webService.updateProduct(id, updates)),
  );

  @override
  Future<void> deleteProduct(int id) async {
    await _webService.deleteProduct(id);
  }

  @override
  Future<List<Cart>> getCarts() async {
    final carts = _asObject(await _webService.getCarts())['carts'];
    if (carts is! List) {
      throw const FormatException('The carts response is invalid.');
    }
    return carts.whereType<Map<String, dynamic>>().map(Cart.fromJson).toList();
  }

  @override
  Future<List<Cart>> getCartsByUser(int userId) async {
    final carts = _asObject(
      await _webService.getCartsByUser(userId),
    )['carts'];
    if (carts is! List) {
      throw const FormatException('The user carts response is invalid.');
    }
    return carts.whereType<Map<String, dynamic>>().map(Cart.fromJson).toList();
  }

  @override
  Future<Cart> addCart({
    required int userId,
    required List<CartItem> products,
  }) async {
    final data = await _webService.addCart({
      'userId': userId,
      'products': products.map((product) => product.toRequestJson()).toList(),
    });
    return Cart.fromJson(_asObject(data));
  }

  Map<String, dynamic> _asObject(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException('The API response is not a JSON object.');
    }
    return data;
  }

  @override
  void close() => _webService.close();
}
