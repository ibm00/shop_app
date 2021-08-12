import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import '../screens/user_product_screen.dart';
import '../screens/orders_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Hello friends!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            title: Text(
              'Shop',
              style: Theme.of(context).textTheme.headline2,
            ),
            leading: Icon(Icons.shop),
            onTap: () => Navigator.pushReplacementNamed(context, "/"),
          ),
          Divider(),
          ListTile(
            title: Text(
              'Orders',
              style: Theme.of(context).textTheme.headline2,
            ),
            leading: Icon(Icons.payment),
            onTap: () =>
                Navigator.pushReplacementNamed(context, OrdersScreen.routeName),
          ),
          Divider(),
          ListTile(
            title: Text(
              'Manage Products',
              style: Theme.of(context).textTheme.headline2,
            ),
            leading: Icon(Icons.edit),
            onTap: () => Navigator.pushReplacementNamed(
                context, UserProductScreen.routeName),
          ),
          Divider(),
          ListTile(
            title: Text(
              'Logout',
              style: Theme.of(context).textTheme.headline2,
            ),
            leading: Icon(Icons.exit_to_app),
            onTap: () {
              Navigator.of(context).pop();

              // To ensure that the app will go to the home route and check the "isAuth" condition, else if the app in other page it will be there even after the logout is pressed.
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
