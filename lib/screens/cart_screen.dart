import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart';
import '../providers/cart_provider.dart' show CartProvider;

import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routName = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart Screen'),
      ),
      body: cart.itemCount == 0
          ? Container(
              margin: EdgeInsets.only(
                bottom: 15,
                left: 15,
                right: 15,
                top: 50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.grey,
                    size: 60,
                  ),
                  Text(
                    'Your shopping card is empty!',
                    style: TextStyle(
                        fontSize: 20, color: Colors.grey, letterSpacing: 2),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Back to shop',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                ],
              ),
            )
          : Column(
              children: [
                Card(
                  margin: EdgeInsets.all(15),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Price'),
                        Spacer(),
                        Chip(
                          label: Text(
                            '\$${cart.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .subtitle1
                                  .color,
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        MyTextButton(),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (ctx, i) => CartItem(
                      productId: cart.item.keys.toList()[i],
                      id: cart.item.values.toList()[i].id,
                      price: cart.item.values.toList()[i].price,
                      quantity: cart.item.values.toList()[i].quantity,
                      title: cart.item.values.toList()[i].title,
                    ),
                    itemCount: cart.itemCount,
                  ),
                )
              ],
            ),
    );
  }
}

class MyTextButton extends StatefulWidget {
  @override
  _MyTextButtonState createState() => _MyTextButtonState();
}

class _MyTextButtonState extends State<MyTextButton> {
  bool _isLoading = false;
  Future<void> orderNow(
    CartProvider cart,
    OrdersProvider orders,
    ScaffoldMessengerState myScaffold,
  ) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await orders.addOrder(
        cart.item.values.toList(),
        cart.totalPrice,
      );
      cart.clear();
    } catch (e) {
      myScaffold.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final myScaffold = ScaffoldMessenger.of(context);
    final cart = Provider.of<CartProvider>(context);
    final orders = Provider.of<OrdersProvider>(context, listen: false);
    return TextButton(
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Text(
              'ORDER NOW',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
      onPressed: () => orderNow(
        cart,
        orders,
        myScaffold,
      ),
    );
  }
}
