import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavourite;
  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    this.isFavourite = false,
  });

  Future<void> toggleFavourite(String token, String userId) async {
    final url = Uri.parse(
        'https://e-commerce-2882c-default-rtdb.firebaseio.com//favouriteData//$userId//$id.json?auth=$token');
    isFavourite = !isFavourite;
    notifyListeners();
    try {
      await http.put(url, body: json.encode(isFavourite));
    } catch (e) {
      isFavourite = !isFavourite;
      notifyListeners();
      print(e);
      throw e;
    }
  }
}
