import 'package:flutter/material.dart';

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
    this.imagePath,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final Color color;
  final String? imagePath;

  MenuItem copyWith({
    String? id,
    String? name,
    String? category,
    int? price,
    IconData? icon,
    Color? color,
    String? imagePath,
    bool clearImagePath = false,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
    );
  }
}

class CartLine {
  CartLine({required this.item, this.quantity = 1});

  final MenuItem item;
  int quantity;
  int get total => item.price * quantity;
}

class CafeTable {
  const CafeTable({required this.number, required this.seats});

  final int number;
  final int seats;
}

class SaleRecord {
  const SaleRecord({
    required this.id,
    required this.orderLabel,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.cashier,
    required this.createdAt,
  });

  final String id;
  final String orderLabel;
  final List<SaleItemRecord> items;
  final int subtotal;
  final int tax;
  final int total;
  final String paymentMethod;
  final String cashier;
  final DateTime createdAt;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

class SaleItemRecord {
  const SaleItemRecord({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  final String productName;
  final int quantity;
  final int unitPrice;
  int get total => quantity * unitPrice;
}

class PendingOrder {
  PendingOrder({
    required this.label,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  final String label;
  final Map<String, CartLine> items;
  final DateTime createdAt;
  DateTime updatedAt;

  int get itemCount => items.values.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => items.values.fold(0, (sum, line) => sum + line.total);
  int get tax => (subtotal * .1).round();
  int get total => subtotal + tax;
}

String rupiah(num value) {
  final digits = value.round().toString();
  final output = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) output.write('.');
    output.write(digits[index]);
  }
  return 'Rp$output';
}
