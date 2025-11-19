import 'product.dart';

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}

class Order {
  final String id;
  final double totalAmount;
  final DateTime date;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.totalAmount,
    required this.items,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'totalAmount': totalAmount,
    'date': date.toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
  };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      totalAmount: json['totalAmount'],
      date: DateTime.parse(json['date']),
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
    );
  }
}