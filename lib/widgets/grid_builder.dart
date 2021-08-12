import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/product_item.dart';

class GridBuilder extends StatelessWidget {
  GridBuilder(this.isShowFavSellected);
  final bool isShowFavSellected;
  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductsProvider>(context);
    final prductItems =
        isShowFavSellected ? productData.favtItem : productData.productItem;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 1.5,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: prductItems[index],
        child: ProductItem(),
      ),
      itemCount: prductItems.length,
    );
  }
}
