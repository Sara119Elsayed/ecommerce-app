class CartItem {
  const CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.thumbnail,
  });

  final int id;
  final String title;
  final double price;
  final int quantity;
  final String thumbnail;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      price: _asDouble(json['price']),
      quantity: _asInt(json['quantity']),
      thumbnail: json['thumbnail']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toRequestJson() => {'id': id, 'quantity': quantity};

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class Cart {
  const Cart({required this.id, required this.userId, required this.products});

  final int id;
  final int userId;
  final List<CartItem> products;

  factory Cart.fromJson(Map<String, dynamic> json) {
    final products = json['products'];
    return Cart(
      id: _asInt(json['id']),
      userId: _asInt(json['userId']),
      products: products is List
          ? products
                .whereType<Map<String, dynamic>>()
                .map(CartItem.fromJson)
                .toList()
          : const [],
    );
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
