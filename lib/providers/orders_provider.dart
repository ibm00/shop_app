import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import '../models/http_exception.dart';
import 'cart_provider.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime date;
  OrderItem({
    this.amount,
    this.date,
    this.id,
    this.products,
  });
}

class OrdersProvider with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String token;
  final String userId;
  final List<OrderItem> ordersData;
  OrdersProvider({this.token, this.ordersData, this.userId})
      : _orders = ordersData ?? [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(
    List<CartItem> cartProducts,
    double total,
  ) async {
    final url = Uri.parse(
        "https://e-commerce-2882c-default-rtdb.firebaseio.com//orders//$userId.json?auth=$token");
    try {
      final time = DateTime.now();
      final res = await http.post(url,
          body: json.encode({
            "amount": total,
            "products": cartProducts
                .map(
                  (e) => {
                    "id": e.id,
                    "title": e.title,
                    "price": e.price,
                    "quantity": e.quantity,
                  },
                )
                .toList(),
            "date": time.toIso8601String(),
          }));

      _orders.insert(
        0,
        OrderItem(
          id: json.decode(res.body)["name"],
          date: time,
          products: cartProducts,
          amount: total,
        ),
      );
      notifyListeners();
    } catch (e) {
      print(e);
      throw MyHttpException("can not order now, try again later!");
    }
  }

  Future<void> feachOrders() async {
    final url = Uri.parse(
      "https://e-commerce-2882c-default-rtdb.firebaseio.com//orders//$userId.json?auth=$token",
    );
    try {
      final res = await http.get(url);
      final ordersMap = json.decode(res.body) as Map;
      if (ordersMap == null) return;
      List<OrderItem> feachedOrders = [];
      ordersMap.forEach((key, value) {
        feachedOrders.add(
          OrderItem(
            id: key,
            amount: value["amount"],
            date: DateTime.parse(value['date']),
            products: (value["products"] as List)
                .map(
                  (e) => CartItem(
                    id: e['id'],
                    price: e["price"],
                    quantity: e["quantity"],
                    title: e["title"],
                  ),
                )
                .toList(),
          ),
        );
        _orders = feachedOrders.reversed.toList();
        notifyListeners();
      });
    } catch (e) {
      print(e);
      throw MyHttpException("can not load orders, try again later!");
    }
  }
}
