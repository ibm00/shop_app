import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_provider.dart';

import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/order-screen';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  //This aproach to avoid calling Future every time the widget rebuild.
  Future _ordersFuture;
  Future<void> ordersFutureFun() async {
    return await Provider.of<OrdersProvider>(context, listen: false)
        .feachOrders();
  }

  @override
  void initState() {
    _ordersFuture = ordersFutureFun();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Your orders'),
      ),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return Center(child: Text("An error happend, try again later!"));
          } else {
            //The consumer shoud be used here to avoid recall the future when notifyLisinter(); in called.
            return Consumer<OrdersProvider>(
              builder: (context, ordersData, child) => ListView.builder(
                itemCount: ordersData.orders.length,
                itemBuilder: (ctx, i) =>
                    OrderItemWidget(orderItem: ordersData.orders[i]),
              ),
            );
          }
        },
      ),
    );
  }
}
