import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

import '../screens/edit_product_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static const String routeName = '/userProduct-screen';
  Future _fetch(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false).fechData(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Your Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routName);
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _fetch(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("An Error Occured!");
          } else {
            return RefreshIndicator(
              onRefresh: () => _fetch(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer<ProductsProvider>(
                  builder: (context, products, child) => ListView.builder(
                    itemBuilder: (context, index) => Column(
                      children: [
                        UserProductItem(
                          id: products.productItem[index].id,
                          imgUrl: products.productItem[index].imageUrl,
                          title: products.productItem[index].title,
                        ),
                        Divider()
                      ],
                    ),
                    itemCount: products.productNum(),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
