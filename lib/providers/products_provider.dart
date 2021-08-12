import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'product_provider.dart';
import '../models/http_exception.dart';

import 'package:http/http.dart' as http;

class ProductsProvider with ChangeNotifier {
  String token;
  String userId;
  List<Product> item;

  ProductsProvider({this.token, this.item, this.userId}) : _item = item ?? [];

  List<Product> _item = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  Future<void> fechData([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://e-commerce-2882c-default-rtdb.firebaseio.com//products.json?auth=$token&$filterString');

    try {
      var res = await http.get(url);
      var data = json.decode(res.body) as Map<String, dynamic> ?? {};
      if (data == null) return;
      url = Uri.parse(
          'https://e-commerce-2882c-default-rtdb.firebaseio.com//favouriteData//$userId.json?auth=$token');
      final favRes = await http.get(url);
      final favMap = json.decode(favRes.body) as Map;
      List<Product> dataList = [];
      data.forEach((prodId, prodData) {
        // print("request done");
        final prodDataMap = prodData as Map;
        dataList.add(
          Product(
            id: prodId,
            title: prodDataMap['title'],
            description: prodDataMap['description'],
            imageUrl: prodDataMap['imageUrl'],
            price: prodData['price'],
            isFavourite: favMap == null ? false : favMap[prodId] ?? false,
          ),
        );
      });
      _item = dataList;
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  List<Product> get productItem {
    return [..._item];
  }

  int productNum() {
    return _item.length;
  }

  List<Product> get favtItem {
    return _item.where((product) => product.isFavourite == true).toList();
  }

  Product findId(String pId) {
    return _item.firstWhere((element) => element.id == pId);
  }

  Future<void> addItem(Product product) async {
    final url = Uri.parse(
        'https://e-commerce-2882c-default-rtdb.firebaseio.com//products.json?auth=$token');
    try {
      var res = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId
        }),
      );

      final newProduct = Product(
        id: json.decode(res.body)['name'],
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );
      _item.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future editItem(Product product) async {
    final url = Uri.parse(
        'https://e-commerce-2882c-default-rtdb.firebaseio.com//products//${product.id}.json?auth=$token');
    try {
      await http.patch(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
        }),
      );
      int editedProductIndex =
          _item.indexWhere((element) => element.id == product.id);
      if (editedProductIndex > 0) {
        _item[editedProductIndex] = product;
      }
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://e-commerce-2882c-default-rtdb.firebaseio.com//products//$id.json?auth=$token');
    final itemIndex = _item.indexWhere((element) => element.id == id);
    Product removedProd = _item[itemIndex];
    _item.removeAt(itemIndex);
    notifyListeners();

    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      _item.insert(itemIndex, removedProd);
      notifyListeners();
      throw MyHttpException("Could not delete product, try again later!");
    }
    removedProd = null;
  }
}
