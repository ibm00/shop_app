import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

import '../providers/cart_provider.dart';

import 'cart_screen.dart';

import '../widgets/grid_builder.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';

enum FavOption { favourite, all }

class ProductOverviewScreen extends StatefulWidget {
  static const routName = "/product-overView-screen";
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _showFavourite = false;
  bool isInit = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    Provider.of<ProductsProvider>(context, listen: false)
        .fechData()
        .catchError((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('An error happend'),
          content: Text('Data can not be loaded'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK")),
          ],
        ),
      );
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FavOption selOption) {
              setState(() {
                if (selOption == FavOption.favourite) {
                  _showFavourite = true;
                } else {
                  _showFavourite = false;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Show favourite only'),
                value: FavOption.favourite,
              ),
              PopupMenuItem(
                child: Text('Show all'),
                value: FavOption.all,
              ),
            ],
            child: Icon(Icons.more_vert),
          ),
          Consumer<CartProvider>(
            builder: (_, value, ch) => Badge(
              child: ch,
              value: value.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.pushNamed(context, CartScreen.routName);
              },
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            await Provider.of<ProductsProvider>(context, listen: false)
                .fechData();
          } catch (_) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('An error happend'),
                content: Text('Data can not be loaded'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("OK")),
                ],
              ),
            );
          }
        },
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : GridBuilder(_showFavourite),
      ),
    );
  }
}
