import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders_provider.dart';

class OrderItemWidget extends StatefulWidget {
  final OrderItem orderItem;
  OrderItemWidget({this.orderItem});

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  var _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.orderItem.amount.toStringAsFixed(2)}'),
            subtitle: Text(
              DateFormat('dd/MM/yyy  hh:mm').format(widget.orderItem.date),
            ),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              height: min(widget.orderItem.products.length * 20.0 + 10, 100),
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                children: widget.orderItem.products
                    .map((e) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${e.title}',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              '${e.quantity} x \$${e.price}',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ))
                    .toList(),
              ),
            )
        ],
      ),
    );
  }
}
