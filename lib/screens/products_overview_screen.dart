import '../screens/user_products_screen.dart';
import '../screens/edit_product_screen.dart';
import '../screens/orders_screen.dart';
import '../widgets/app_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

import 'dart:io';
import '../widgets/products_grid.dart';
import '../providers/auth.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    _pages = [
      {
        'page': ProductsGrid(_showOnlyFavorites),
        'title': 'Shopify',
      },
      {
        'page': ProductsGrid(_showOnlyFavorites = true),
        'title': 'Your Favorite',
      },
      {
        'page': OrdersScreen(),
        'title': 'Your Orders',
      },
      {
        'page': EditProductScreen(),
        'title': 'Add Product',
      },
      {
        'page': UserProductsScreen(),
        'title': 'Edit Product',
      },
      {
        'page': CartScreen(),
        'title': 'Your Cart',
      },
    ];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    void onTabTapped(int index) {}

    return Scaffold(
      appBar: Platform.isAndroid
          ? AppBar(
              title: Text('Shopify'),
              actions: <Widget>[
                PopupMenuButton(
                  onSelected: (FilterOptions selectedValue) {
                    // print(selectedValue);
                    setState(() {
                      if (selectedValue == FilterOptions.Favorites) {
                        _showOnlyFavorites = true;
                      } else {
                        _showOnlyFavorites = false;
                      }
                    });
                  },
                  icon: Icon(
                    Icons.more_vert,
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('Only Favorites'),
                      value: FilterOptions.Favorites,
                    ),
                    PopupMenuItem(
                      child: Text('Show All'),
                      value: FilterOptions.All,
                    ),
                  ],
                ),
                Consumer<Cart>(
                  builder: (_, cart, ch) => Badge(
                    child: ch,
                    value: cart.itemCount.toString(),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.shopping_cart,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(CartScreen.routeName);
                    },
                  ),
                ),
              ],
            )
          : CupertinoNavigationBar(
              middle: Text(_pages[_selectedPageIndex]['title']),
              trailing: IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  Provider.of<Auth>(context, listen: false).logout();
                },
              ),
            ),
      drawer: Platform.isAndroid ? AppDrawer() : Container(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Platform.isAndroid
              ? ProductsGrid(_showOnlyFavorites)
              : _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: Platform.isIOS
          ? CupertinoTabBar(
              onTap: _selectPage,
              inactiveColor: Colors.black,
              activeColor: Theme.of(context).primaryColor,
              currentIndex: _selectedPageIndex,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.shop),
                  title: Text('Shop'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  title: Text('Favorites'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.payment),
                  title: Text('Orders'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_a_photo),
                  title: Text('Add'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.edit),
                  title: Text('Products'),
                ),
                BottomNavigationBarItem(
                  icon: Consumer<Cart>(
                    builder: (_, cart, ch) => Badge(
                      child: ch,
                      value: cart.itemCount.toString(),
                    ),
                    child: Icon(Icons.shopping_cart),
                  ),
                  title: Text('Cart'),
                ),
              ],
            )
          : null,
    );
  }
}
