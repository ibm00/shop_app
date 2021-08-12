import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;
  CartItem({this.id, this.price, this.quantity, this.title});
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _item = {};

  Map<String, CartItem> get item {
    return {..._item};
  }

  void addItem(String productId, String title, double price) {
    if (_item.containsKey(productId)) {
      _item.update(
        productId,
        (oldCardItem) => CartItem(
          id: oldCardItem.id,
          price: oldCardItem.price,
          title: oldCardItem.title,
          quantity: oldCardItem.quantity + 1,
        ),
      );
    } else {
      _item.putIfAbsent(
        productId,
        () => CartItem(
          title: title,
          id: DateTime.now().toString(),
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  int get itemCount {
    return _item.length;
  }

  double get totalPrice {
    double totPrice = 0.0;
    _item.forEach((key, value) {
      totPrice += value.price * value.quantity;
    });
    return totPrice;
  }

  void deleteItem(String productId) {
    _item.remove(productId);
    notifyListeners();
  }

  void deleteRecentlyAddedItem(String productId) {
    if (_item[productId].quantity == 1)
      deleteItem(productId);
    else {
      _item.update(
        productId,
        (oldCartItem) => CartItem(
          id: oldCartItem.id,
          price: oldCartItem.price,
          title: oldCartItem.title,
          quantity: oldCartItem.quantity - 1,
        ),
      );
      notifyListeners();
    }
  }

  void clear() {
    _item = {};
    notifyListeners();
  }
}
