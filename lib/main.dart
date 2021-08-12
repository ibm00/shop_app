import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/product_overview_screen.dart';
import 'screens/splash_screen.dart';

import 'providers/orders_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/products_provider.dart';

import 'screens/cart_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/user_product_screen.dart';
import 'screens/orders_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          update: (_, auth, oldProduct) => ProductsProvider(
            token: auth.token,
            userId: auth.userId,
            item: oldProduct == null ? [] : oldProduct.productItem,
          ),
          create: (_) => ProductsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          create: (_) => OrdersProvider(),
          update: (_, auth, oldProduct) => OrdersProvider(
            token: auth.token,
            userId: auth.userId,
            ordersData: oldProduct == null ? [] : oldProduct.orders,
          ),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, authPorv, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            accentColor: Colors.deepOrange,
            fontFamily: 'Ubuntu',
            textTheme: TextTheme(
              headline2: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              subtitle1: TextStyle(fontSize: 17),
            ),
          ),
          routes: {
            "/": (_) => authPorv.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: authPorv.autoLogin(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return SplashScreen();
                      else
                        return AuthScreen();
                    },
                  ),
            ProductDetailsScreen.routeName: (_) => ProductDetailsScreen(),
            CartScreen.routName: (_) => CartScreen(),
            OrdersScreen.routeName: (_) => OrdersScreen(),
            UserProductScreen.routeName: (_) => UserProductScreen(),
            EditProductScreen.routName: (_) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
