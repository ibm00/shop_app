import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

import '../screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String title;
  final String imgUrl;
  final String id;
  UserProductItem({
    @required this.imgUrl,
    @required this.title,
    @required this.id,
  });
  @override
  Widget build(BuildContext context) {
    final scafMass = ScaffoldMessenger.of(context);
    var _product = Provider.of<ProductsProvider>(context, listen: false);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imgUrl),
      ),
      trailing: Container(
        width: 98,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  EditProductScreen.routName,
                  arguments: id,
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).errorColor,
              ),
              onPressed: () async {
                try {
                  await _product.deleteProduct(id);
                  scafMass.clearSnackBars();
                  scafMass.showSnackBar(
                    SnackBar(
                      content: Text(
                        "Deleted Successfully",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } catch (e) {
                  scafMass.clearSnackBars();
                  scafMass.showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
