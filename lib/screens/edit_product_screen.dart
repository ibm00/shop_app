import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const String routName = "/edit-screen";
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocuseNode = FocusNode();
  final _desFocuseNode = FocusNode();
  final _imgFocuseNode = FocusNode();
  TextEditingController _imgUrlController = TextEditingController();
  var _product = Product(
    id: null,
    title: '',
    description: '',
    imageUrl: '',
    price: 0,
  );
  final _form = GlobalKey<FormState>();
  String _pageTitle = '';
  bool _intstate = true;
  bool isEdit = false;
  bool _isLoading = false;

  @override
  void initState() {
    _imgFocuseNode.addListener(updateImg);
    super.initState();
  }

  @override
  void dispose() {
    _priceFocuseNode.dispose();
    _desFocuseNode.dispose();
    _imgUrlController.dispose();
    _imgFocuseNode.removeListener(updateImg);
    _imgFocuseNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_intstate) {
      final id = ModalRoute.of(context).settings.arguments as String;
      isEdit = (id != null);
      _pageTitle = isEdit ? "Edit product" : "Add new product";
      var _productPrvider =
          Provider.of<ProductsProvider>(context, listen: false);

      if (isEdit) {
        _product = _productPrvider.findId(id);
      }
      _imgUrlController.text = _product.imageUrl;
      _intstate = false;
    }

    super.didChangeDependencies();
  }

  void updateImg() {
    if (!_imgFocuseNode.hasFocus) {
      if (_imgUrlController.text.isNotEmpty &&
          !_imgUrlController.text.startsWith('http') &&
          !_imgUrlController.text.startsWith('https')) return;
      setState(() {});
    }
  }

  Future<void> saveForm(BuildContext ctx) async {
    if (!_form.currentState.validate()) return;
    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    var _productPrvider = Provider.of<ProductsProvider>(ctx, listen: false);
    try {
      if (isEdit) {
        await _productPrvider.editItem(_product);
      } else {
        await _productPrvider.addItem(_product);
      }
    } catch (error) {
      await showDialog<Null>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('An error happend.'),
          content: Text('Some thing went wrong.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } finally {
      Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: () => saveForm(context))
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _product.title,
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocuseNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) return "Enter the title.";
                          return null;
                        },
                        onSaved: (value) {
                          _product = Product(
                            id: _product.id,
                            title: value,
                            description: _product.description,
                            imageUrl: _product.imageUrl,
                            price: _product.price,
                            isFavourite: _product.isFavourite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _product.price.toString(),
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocuseNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_desFocuseNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Enter the price.";
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid price value!';
                          }
                          if (double.parse(value) <= 0) {
                            return "Please enter a number greater than zero.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _product = Product(
                            id: _product.id,
                            title: _product.title,
                            description: _product.description,
                            imageUrl: _product.imageUrl,
                            price: double.parse(value),
                            isFavourite: _product.isFavourite,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _product.description,
                        decoration: InputDecoration(labelText: 'Description'),
                        keyboardType: TextInputType.multiline,
                        focusNode: _desFocuseNode,
                        maxLines: 3,
                        validator: (value) {
                          if (value.isEmpty) return "Enter the description.";
                          if (value.length < 10) {
                            return "The description must be more than 10 charactars.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _product = Product(
                            id: _product.id,
                            title: _product.title,
                            description: value,
                            imageUrl: _product.imageUrl,
                            price: _product.price,
                            isFavourite: _product.isFavourite,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8, right: 8),
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imgUrlController.text.isEmpty
                                ? Center(child: Text('Enter a url'))
                                : FittedBox(
                                    fit: BoxFit.cover,
                                    child:
                                        Image.network(_imgUrlController.text),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              //initialValue: _product.imageUrl,
                              decoration:
                                  InputDecoration(labelText: "Image url"),
                              textInputAction: TextInputAction.done,
                              controller: _imgUrlController,
                              keyboardType: TextInputType.url,
                              focusNode: _imgFocuseNode,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter the Url.";
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return "Enter a valid url.";
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                saveForm(context);
                              },
                              onSaved: (value) {
                                _product = Product(
                                  id: _product.id,
                                  title: _product.title,
                                  description: _product.description,
                                  imageUrl: value,
                                  price: _product.price,
                                  isFavourite: _product.isFavourite,
                                );
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
