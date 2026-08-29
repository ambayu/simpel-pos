import 'package:flutter/material.dart';

import 'models.dart';

class PosStore extends ChangeNotifier {
  final tables = List.generate(
    16,
    (index) => CafeTable(number: index + 1, seats: index % 3 == 0 ? 4 : 2),
  );

  final cart = <String, CartLine>{};
  final pendingOrders = <String, PendingOrder>{};
  final transactions = <SaleRecord>[];
  int todaySales = 2845000;
  int todayTransactions = 48;
  String role = 'Kasir';
  String? activeOrder;

  final menu = <MenuItem>[
    MenuItem(
      id: '1',
      name: 'Kopi Susu Gula Aren',
      category: 'Kopi',
      price: 22000,
      icon: Icons.coffee_rounded,
      color: Color(0xFFC67C4E),
    ),
    MenuItem(
      id: '2',
      name: 'Cappuccino',
      category: 'Kopi',
      price: 25000,
      icon: Icons.local_cafe_rounded,
      color: Color(0xFF9B6B43),
    ),
    MenuItem(
      id: '3',
      name: 'Americano',
      category: 'Kopi',
      price: 18000,
      icon: Icons.coffee_maker_rounded,
      color: Color(0xFF6F4E37),
    ),
    MenuItem(
      id: '4',
      name: 'Matcha Latte',
      category: 'Non Kopi',
      price: 26000,
      icon: Icons.emoji_food_beverage_rounded,
      color: Color(0xFF7E9F72),
    ),
    MenuItem(
      id: '5',
      name: 'Chocolate Cream',
      category: 'Non Kopi',
      price: 24000,
      icon: Icons.local_drink_rounded,
      color: Color(0xFF8B5E3C),
    ),
    MenuItem(
      id: '6',
      name: 'Lychee Tea',
      category: 'Non Kopi',
      price: 20000,
      icon: Icons.local_bar_rounded,
      color: Color(0xFFE29A68),
    ),
    MenuItem(
      id: '7',
      name: 'Croissant Butter',
      category: 'Makanan',
      price: 19000,
      icon: Icons.bakery_dining_rounded,
      color: Color(0xFFD9A15B),
    ),
    MenuItem(
      id: '8',
      name: 'Nasi Goreng Kampung',
      category: 'Makanan',
      price: 32000,
      icon: Icons.rice_bowl_rounded,
      color: Color(0xFFB45D3C),
    ),
    MenuItem(
      id: '9',
      name: 'Chicken Katsu',
      category: 'Makanan',
      price: 35000,
      icon: Icons.lunch_dining_rounded,
      color: Color(0xFFD07A43),
    ),
    MenuItem(
      id: '10',
      name: 'French Fries',
      category: 'Snack',
      price: 18000,
      icon: Icons.fastfood_rounded,
      color: Color(0xFFE7A83E),
    ),
    MenuItem(
      id: '11',
      name: 'Onion Ring',
      category: 'Snack',
      price: 20000,
      icon: Icons.tapas_rounded,
      color: Color(0xFFD18D40),
    ),
    MenuItem(
      id: '12',
      name: 'Pisang Cokelat',
      category: 'Snack',
      price: 21000,
      icon: Icons.cookie_rounded,
      color: Color(0xFFB8794A),
    ),
  ];

  int get cartCount => cart.values.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => cart.values.fold(0, (sum, line) => sum + line.total);
  int get tax => (subtotal * .1).round();
  int get total => subtotal + tax;

  Set<int> get occupiedTables => pendingOrders.keys
      .where((label) => label.startsWith('Meja '))
      .map((label) => int.tryParse(label.replaceAll(RegExp(r'[^0-9]'), '')))
      .whereType<int>()
      .toSet();

  List<String> get categories {
    final values = menu.map((item) => item.category).toSet().toList()..sort();
    return ['Semua', ...values];
  }

  void setRole(String value) {
    role = value;
    notifyListeners();
  }

  void startOrder(String label) {
    activeOrder = label;
    cart.clear();
    final pending = pendingOrders[label];
    if (pending != null) {
      for (final entry in pending.items.entries) {
        cart[entry.key] = CartLine(
          item: entry.value.item,
          quantity: entry.value.quantity,
        );
      }
    }
    notifyListeners();
  }

  String nextTakeAwayLabel() {
    var number = 1;
    while (pendingOrders.containsKey(
      'Take Away #${number.toString().padLeft(2, '0')}',
    )) {
      number++;
    }
    return 'Take Away #${number.toString().padLeft(2, '0')}';
  }

  void savePendingOrder() {
    if (activeOrder == null || cart.isEmpty) return;
    final now = DateTime.now();
    final current = pendingOrders[activeOrder];
    pendingOrders[activeOrder!] = PendingOrder(
      label: activeOrder!,
      items: {
        for (final entry in cart.entries)
          entry.key: CartLine(
            item: entry.value.item,
            quantity: entry.value.quantity,
          ),
      },
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );
    cart.clear();
    activeOrder = null;
    notifyListeners();
  }

  void add(MenuItem item) {
    final current = cart[item.id];
    current == null ? cart[item.id] = CartLine(item: item) : current.quantity++;
    notifyListeners();
  }

  void remove(MenuItem item) {
    final current = cart[item.id];
    if (current == null) return;
    current.quantity--;
    if (current.quantity <= 0) cart.remove(item.id);
    notifyListeners();
  }

  void addProduct({
    required String name,
    required String category,
    required int price,
    String? imagePath,
  }) {
    final palette = <Color>[
      const Color(0xFFC67C4E),
      const Color(0xFF7E9F72),
      const Color(0xFFD9A15B),
      const Color(0xFFB45D3C),
    ];
    menu.add(
      MenuItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        category: category.trim(),
        price: price,
        icon: Icons.restaurant_menu_rounded,
        color: palette[menu.length % palette.length],
        imagePath: imagePath,
      ),
    );
    notifyListeners();
  }

  void updateProduct(
    MenuItem current, {
    required String name,
    required String category,
    required int price,
    String? imagePath,
    bool clearImagePath = false,
  }) {
    final index = menu.indexWhere((item) => item.id == current.id);
    if (index < 0) return;
    menu[index] = MenuItem(
      id: current.id,
      name: name.trim(),
      category: category.trim(),
      price: price,
      icon: current.icon,
      color: current.color,
      imagePath: clearImagePath ? null : (imagePath ?? current.imagePath),
    );
    notifyListeners();
  }

  void deleteProduct(String id) {
    menu.removeWhere((item) => item.id == id);
    cart.remove(id);
    notifyListeners();
  }

  void addTable({required int seats}) {
    final nextNumber = tables.isEmpty
        ? 1
        : tables.map((table) => table.number).reduce((a, b) => a > b ? a : b) +
              1;
    tables.add(CafeTable(number: nextNumber, seats: seats));
    notifyListeners();
  }

  void deleteTable(int number) {
    if (occupiedTables.contains(number)) return;
    tables.removeWhere((table) => table.number == number);
    notifyListeners();
  }

  SaleRecord? completeOrder(String paymentMethod) {
    if (cart.isEmpty) return null;
    final now = DateTime.now();
    final transaction = SaleRecord(
      id: 'TRX-${now.millisecondsSinceEpoch}',
      orderLabel: activeOrder ?? 'Take Away',
      items: cart.values
          .map(
            (line) => SaleItemRecord(
              productName: line.item.name,
              quantity: line.quantity,
              unitPrice: line.item.price,
            ),
          )
          .toList(),
      subtotal: subtotal,
      tax: tax,
      total: total,
      paymentMethod: paymentMethod,
      cashier: role,
      createdAt: now,
    );
    transactions.insert(0, transaction);
    todaySales += total;
    todayTransactions++;
    if (activeOrder != null) pendingOrders.remove(activeOrder);
    cart.clear();
    activeOrder = null;
    notifyListeners();
    return transaction;
  }
}
