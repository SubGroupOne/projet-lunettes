import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final String desc;
  final int
  price; // in centimes or smallest unit; here we use integer (e.g., 45000)
  final String image;

  CartItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    required this.image,
  });
}

class Cart extends ChangeNotifier {
  Cart._privateConstructor();
  static final Cart instance = Cart._privateConstructor();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addFromMap(Map<String, String> p) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final name = p['name'] ?? 'Produit';
    final desc = p['desc'] ?? '';
    final image = p['image'] ?? '';
    final price = _parsePrice(p['price']);
    _items.add(
      CartItem(id: id, name: name, desc: desc, price: price, image: image),
    );
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int get subtotal => _items.fold<int>(0, (s, i) => s + i.price);

  bool get isEmpty => _items.isEmpty;

  static int _parsePrice(String? s) {
    if (s == null) return 0;
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    try {
      return int.parse(digits);
    } catch (_) {
      return 0;
    }
  }

  static String formatPrice(int value) {
    // simple formatting with spaces every 3 digits from right
    final s = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final pos = s.length - i;
      buffer.write(s[i]);
      if (pos > 1 && pos % 3 == 1) buffer.write(' ');
    }
    return buffer.toString();
  }
}
