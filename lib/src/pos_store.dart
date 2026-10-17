import 'package:flutter/material.dart';

import 'demo_data.dart';
import 'models.dart';
import 'theme/app_theme.dart';

class PosStore extends ChangeNotifier {
  PosStore({this.seedDemoData = false}) {
    _seedTables();
    if (seedDemoData) {
      _seedInitialData();
    }
  }

  final bool seedDemoData;
  static const taxRate = .1;

  final tables = <CafeTable>[];
  final cart = <String, CartLine>{};
  final pendingOrders = <String, PendingOrder>{};
  final transactions = <SaleRecord>[];
  final reservedTables = <int, String>{};

  int discount = 0;
  String role = 'Kasir';
  String currentUsername = 'kasir';
  String? activeOrder;

  // Daftar Akun Pengguna
  final users = <UserAccount>[
    const UserAccount(username: 'owner', password: '123', role: 'Owner'),
    const UserAccount(username: 'admin', password: '123', role: 'Admin'),
    const UserAccount(username: 'kasir', password: '123', role: 'Kasir'),
    const UserAccount(username: 'pegawai', password: '123', role: 'Pegawai'),
  ];

  // Matriks Akses Peran (Permission Bebas)
  final Map<String, Set<SimpelPermission>> rolePermissions = {
    'Owner': SimpelPermission.values.toSet(),
    'Admin': {
      SimpelPermission.dashboard,
      SimpelPermission.table,
      SimpelPermission.tableAksi,
      SimpelPermission.order,
      SimpelPermission.orderAksi,
      SimpelPermission.report,
      SimpelPermission.reportAksi,
      SimpelPermission.product,
      SimpelPermission.productAksi,
      SimpelPermission.stock,
      SimpelPermission.stockAksi,
      SimpelPermission.settings,
    },
    'Kasir': {
      SimpelPermission.dashboard,
      SimpelPermission.table,
      SimpelPermission.order,
      SimpelPermission.orderAksi,
      SimpelPermission.report,
      SimpelPermission.stock,
    },
    'Pegawai': {
      SimpelPermission.dashboard,
      SimpelPermission.table,
      SimpelPermission.order,
    },
  };

  bool hasPermission(SimpelPermission permission) {
    if (role == 'Owner') return true;
    final perms = rolePermissions[role];
    if (perms == null) return false;
    return perms.contains(permission);
  }

  void togglePermission(String targetRole, SimpelPermission permission, bool allow) {
    final current = rolePermissions[targetRole] ?? <SimpelPermission>{};
    if (allow) {
      current.add(permission);
    } else {
      current.remove(permission);
    }
    rolePermissions[targetRole] = current;
    notifyListeners();
  }

  bool authenticate(String inputRole, String username, String password) {
    final user = users.firstWhere(
      (u) =>
          u.role.toLowerCase() == inputRole.toLowerCase() &&
          u.username.toLowerCase() == username.trim().toLowerCase(),
      orElse: () => const UserAccount(username: '', password: '', role: ''),
    );
    if (user.username.isEmpty) return false;
    if (user.password != password.trim()) return false;

    role = user.role;
    currentUsername = user.username;
    notifyListeners();
    return true;
  }

  void ownerUpdateUserCredentials({
    required String originalUsername,
    required String newUsername,
    String? newPassword,
  }) {
    final idx = users.indexWhere((u) => u.username.toLowerCase() == originalUsername.toLowerCase());
    if (idx < 0) return;
    final old = users[idx];
    users[idx] = old.copyWith(
      username: newUsername.trim().isEmpty ? old.username : newUsername.trim(),
      password: (newPassword != null && newPassword.trim().isNotEmpty) ? newPassword.trim() : old.password,
    );
    if (currentUsername.toLowerCase() == originalUsername.toLowerCase()) {
      currentUsername = users[idx].username;
    }
    notifyListeners();
  }

  void adjustStock(String productId, int newStock) {
    final idx = menu.indexWhere((m) => m.id == productId);
    if (idx < 0) return;
    menu[idx] = menu[idx].copyWith(stock: newStock.clamp(0, 999999));
    notifyListeners();
  }

  void addStock(String productId, int delta) {
    final idx = menu.indexWhere((m) => m.id == productId);
    if (idx < 0) return;
    final nextStock = (menu[idx].stock + delta).clamp(0, 999999);
    menu[idx] = menu[idx].copyWith(stock: nextStock);
    notifyListeners();
  }

  final menu = <MenuItem>[
    MenuItem(
      id: '1',
      name: 'Collagen Soup',
      category: 'HOTPOT',
      price: 35000,
      icon: Icons.soup_kitchen_rounded,
      color: AppColors.primary,
      description: 'Rp 350/gram (Porsi gramasi hotpot)',
      favorite: true,
      variants: const [
        MenuVariant(label: '100 gram'),
        MenuVariant(label: '200 gram', extraPrice: 35000),
        MenuVariant(label: '300 gram', extraPrice: 70000),
        MenuVariant(label: '500 gram', extraPrice: 140000),
      ],
    ),
    MenuItem(
      id: '2',
      name: 'Mala Collagen Soup',
      category: 'HOTPOT',
      price: 35000,
      icon: Icons.soup_kitchen_rounded,
      color: AppColors.primary,
      description: 'Rp 350/gram (Porsi gramasi hotpot)',
      favorite: true,
      variants: const [
        MenuVariant(label: '100 gram'),
        MenuVariant(label: '200 gram', extraPrice: 35000),
        MenuVariant(label: '300 gram', extraPrice: 70000),
        MenuVariant(label: '500 gram', extraPrice: 140000),
      ],
    ),
    MenuItem(
      id: '3',
      name: 'Curry Collagen Soup (No Santan)',
      category: 'HOTPOT',
      price: 35000,
      icon: Icons.soup_kitchen_rounded,
      color: AppColors.primary,
      description: 'Rp 350/gram (Porsi gramasi hotpot)',
      variants: const [
        MenuVariant(label: '100 gram'),
        MenuVariant(label: '200 gram', extraPrice: 35000),
        MenuVariant(label: '300 gram', extraPrice: 70000),
        MenuVariant(label: '500 gram', extraPrice: 140000),
      ],
    ),
    MenuItem(
      id: '4',
      name: 'Collagen Vegetarian Soup',
      category: 'HOTPOT',
      price: 35000,
      icon: Icons.soup_kitchen_rounded,
      color: AppColors.primary,
      description: 'Rp 350/gram (Porsi gramasi hotpot)',
      variants: const [
        MenuVariant(label: '100 gram'),
        MenuVariant(label: '200 gram', extraPrice: 35000),
        MenuVariant(label: '300 gram', extraPrice: 70000),
        MenuVariant(label: '500 gram', extraPrice: 140000),
      ],
    ),
    MenuItem(
      id: '5',
      name: 'Mala Collagen Vegetarian Soup',
      category: 'HOTPOT',
      price: 35000,
      icon: Icons.soup_kitchen_rounded,
      color: AppColors.primary,
      description: 'Rp 350/gram (Porsi gramasi hotpot)',
      variants: const [
        MenuVariant(label: '100 gram'),
        MenuVariant(label: '200 gram', extraPrice: 35000),
        MenuVariant(label: '300 gram', extraPrice: 70000),
        MenuVariant(label: '500 gram', extraPrice: 140000),
      ],
    ),
    MenuItem(
      id: '6',
      name: 'Braised Special Haisom',
      category: 'HAISOM',
      price: 800000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
    ),
    MenuItem(
      id: '7',
      name: 'Haisom LongChuan',
      category: 'HAISOM',
      price: 250000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      favorite: true,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 200000),
      ],
    ),
    MenuItem(
      id: '8',
      name: 'Kepiting Soka Lada Hitam',
      category: 'KEPITING SOKA',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 45000),
        MenuVariant(label: 'Porsi L', extraPrice: 120000),
      ],
    ),
    MenuItem(
      id: '9',
      name: 'Kepiting Soka X.O Bao',
      category: 'KEPITING SOKA',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 45000),
        MenuVariant(label: 'Porsi L', extraPrice: 120000),
      ],
    ),
    MenuItem(
      id: '10',
      name: 'Ikan Asam Pedas (Steam)',
      category: 'IKAN',
      price: 250000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      description: 'Harga mulai dari',
      favorite: true,
    ),
    MenuItem(
      id: '11',
      name: 'Ikan Asam Manis',
      category: 'IKAN',
      price: 250000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
    ),
    MenuItem(
      id: '12',
      name: 'Ikan Tauco',
      category: 'IKAN',
      price: 250000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
    ),
    MenuItem(
      id: '13',
      name: 'Ikan Saus Nyonya Special',
      category: 'IKAN',
      price: 250000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      description: 'Harga mulai dari',
    ),
    MenuItem(
      id: '14',
      name: 'Ikan Crispy Saus Thai',
      category: 'IKAN',
      price: 250000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      description: 'Harga mulai dari',
    ),
    MenuItem(
      id: '15',
      name: 'Ikan Bakar Bumbu Rujak',
      category: 'IKAN',
      price: 250000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
    ),
    MenuItem(
      id: '16',
      name: 'Ikan Suan Cai Yi Bebek Asap',
      category: 'IKAN',
      price: 350000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      description: 'Harga mulai dari',
    ),
    MenuItem(
      id: '17',
      name: 'Ikan Steam HongKong',
      category: 'IKAN',
      price: 250000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      description: 'Harga mulai dari',
    ),
    MenuItem(
      id: '18',
      name: 'Ikan Mala Szechuan',
      category: 'IKAN',
      price: 350000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      description: 'Harga mulai dari',
    ),
    MenuItem(
      id: '19',
      name: 'Ikan Bakar Portugues',
      category: 'IKAN',
      price: 250000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
    ),
    MenuItem(
      id: '20',
      name: 'Ikan 3 Cup Sauce',
      category: 'IKAN',
      price: 250000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
    ),
    MenuItem(
      id: '21',
      name: 'Ikan Saus Curry',
      category: 'IKAN',
      price: 250000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
    ),
    MenuItem(
      id: '22',
      name: 'Ikan Fillet Bakar Portugues',
      category: 'IKAN FILLET',
      price: 60000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 20000),
        MenuVariant(label: 'Porsi L', extraPrice: 90000),
      ],
    ),
    MenuItem(
      id: '23',
      name: 'Ikan Fillet Saus Singapur',
      category: 'IKAN FILLET',
      price: 60000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 20000),
        MenuVariant(label: 'Porsi L', extraPrice: 90000),
      ],
    ),
    MenuItem(
      id: '24',
      name: 'Ikan Fillet 3 Cup Sauce',
      category: 'IKAN FILLET',
      price: 60000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 20000),
        MenuVariant(label: 'Porsi L', extraPrice: 90000),
      ],
    ),
    MenuItem(
      id: '25',
      name: 'Ikan Fillet Sauce Curry',
      category: 'IKAN FILLET',
      price: 60000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 20000),
        MenuVariant(label: 'Porsi L', extraPrice: 90000),
      ],
    ),
    MenuItem(
      id: '26',
      name: 'Ikan Fillet Sauce Lychee',
      category: 'IKAN FILLET',
      price: 60000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 20000),
        MenuVariant(label: 'Porsi L', extraPrice: 90000),
      ],
    ),
    MenuItem(
      id: '27',
      name: 'Ikan Fillet Goreng Spesial',
      category: 'IKAN FILLET',
      price: 60000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 20000),
        MenuVariant(label: 'Porsi L', extraPrice: 90000),
      ],
    ),
    MenuItem(
      id: '28',
      name: 'Udang Bakar Portuguese',
      category: 'UDANG',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 55000),
        MenuVariant(label: 'Porsi L', extraPrice: 170000),
      ],
    ),
    MenuItem(
      id: '29',
      name: 'Udang Goreng Spesial',
      category: 'UDANG',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 55000),
        MenuVariant(label: 'Porsi L', extraPrice: 170000),
      ],
    ),
    MenuItem(
      id: '30',
      name: 'Udang Saus X.O',
      category: 'UDANG',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 55000),
        MenuVariant(label: 'Porsi L', extraPrice: 170000),
      ],
    ),
    MenuItem(
      id: '31',
      name: 'Udang Saus Tauco',
      category: 'UDANG',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 55000),
        MenuVariant(label: 'Porsi L', extraPrice: 170000),
      ],
    ),
    MenuItem(
      id: '32',
      name: 'Udang KamHeong',
      category: 'UDANG',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 55000),
        MenuVariant(label: 'Porsi L', extraPrice: 170000),
      ],
    ),
    MenuItem(
      id: '33',
      name: 'Udang Curry Nenas',
      category: 'UDANG',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 55000),
        MenuVariant(label: 'Porsi L', extraPrice: 170000),
      ],
    ),
    MenuItem(
      id: '34',
      name: 'Udang Saus Lychee',
      category: 'UDANG',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 55000),
        MenuVariant(label: 'Porsi L', extraPrice: 170000),
      ],
    ),
    MenuItem(
      id: '35',
      name: 'Udang Sambel Legend',
      category: 'UDANG',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 55000),
        MenuVariant(label: 'Porsi L', extraPrice: 170000),
      ],
    ),
    MenuItem(
      id: '36',
      name: 'Udang 3 Cup Sauce',
      category: 'UDANG',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 55000),
        MenuVariant(label: 'Porsi L', extraPrice: 170000),
      ],
    ),
    MenuItem(
      id: '37',
      name: 'Bebek Asap Nenas Saus Plam',
      category: 'BEBEK PEKING',
      price: 125000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 105000),
      ],
    ),
    MenuItem(
      id: '38',
      name: 'Bebek Asap 2 Kombinasi',
      category: 'BEBEK PEKING',
      price: 125000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 105000),
      ],
    ),
    MenuItem(
      id: '39',
      name: 'Kuecap Kombinasi',
      category: 'BEBEK PEKING',
      price: 80000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 45000),
        MenuVariant(label: 'Porsi L', extraPrice: 120000),
      ],
    ),
    MenuItem(
      id: '40',
      name: 'Peking Duck Roll With Lotus Bun',
      category: 'BEBEK PEKING',
      price: 100000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      description: 'Porsi isi 3 pcs',
      favorite: true,
    ),
    MenuItem(
      id: '41',
      name: 'Crispy Peking Duck Roll',
      category: 'BEBEK PEKING',
      price: 80000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 70000),
      ],
    ),
    MenuItem(
      id: '42',
      name: 'Angsio Kombinasi',
      category: 'BEBEK PEKING',
      price: 60000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 60000),
      ],
    ),
    MenuItem(
      id: '43',
      name: 'Ayam Saus Tape',
      category: 'AYAM / CHICKEN',
      price: 80000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 55000),
        MenuVariant(label: 'Porsi L', extraPrice: 170000),
      ],
    ),
    MenuItem(
      id: '44',
      name: 'Ayam Goreng Cheese',
      category: 'AYAM / CHICKEN',
      price: 125000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 125000),
      ],
    ),
    MenuItem(
      id: '45',
      name: 'Ayam Saus Korea',
      category: 'AYAM / CHICKEN',
      price: 60000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 75000),
        MenuVariant(label: 'Porsi L', extraPrice: 190000),
      ],
    ),
    MenuItem(
      id: '46',
      name: 'Korean Bean Chicken Satay',
      category: 'AYAM / CHICKEN',
      price: 80000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 70000),
      ],
    ),
    MenuItem(
      id: '47',
      name: 'Ayam Kampung Hainam',
      category: 'AYAM / CHICKEN',
      price: 150000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 100000),
      ],
    ),
    MenuItem(
      id: '48',
      name: 'Ayam Kung Pao',
      category: 'AYAM / CHICKEN',
      price: 80000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 70000),
      ],
    ),
    MenuItem(
      id: '49',
      name: 'Ayam 2 Kombinasi',
      category: 'AYAM / CHICKEN',
      price: 130000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 110000),
      ],
    ),
    MenuItem(
      id: '50',
      name: 'Ayam Goreng KamHeong',
      category: 'AYAM / CHICKEN',
      price: 70000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      favorite: true,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 60000),
        MenuVariant(label: 'Porsi L', extraPrice: 180000),
      ],
    ),
    MenuItem(
      id: '51',
      name: 'Ayam Bumbu Rujak',
      category: 'AYAM / CHICKEN',
      price: 150000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 100000),
      ],
    ),
    MenuItem(
      id: '52',
      name: 'Ayam Teh Kering PortKlang',
      category: 'AYAM / CHICKEN',
      price: 250000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
    ),
    MenuItem(
      id: '53',
      name: 'Salted Kampung Chicken',
      category: 'AYAM / CHICKEN',
      price: 250000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
    ),
    MenuItem(
      id: '54',
      name: 'Ayam Goreng Serundeng',
      category: 'AYAM / CHICKEN',
      price: 150000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 100000),
      ],
    ),
    MenuItem(
      id: '55',
      name: 'Mantho Ayam BlackBean Sauce',
      category: 'AYAM FILLET',
      price: 100000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 50000),
      ],
    ),
    MenuItem(
      id: '56',
      name: 'Ayam Tim Ikan Asin',
      category: 'AYAM FILLET',
      price: 130000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 120000),
      ],
    ),
    MenuItem(
      id: '57',
      name: 'Ke kien / Ke Keng',
      category: 'AYAM FILLET',
      price: 100000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 100000),
      ],
    ),
    MenuItem(
      id: '58',
      name: 'Ayam Goreng Thai',
      category: 'AYAM FILLET',
      price: 60000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 60000),
      ],
    ),
    MenuItem(
      id: '59',
      name: 'Szechuan Mala Chicken',
      category: 'AYAM FILLET',
      price: 70000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 50000),
      ],
    ),
    MenuItem(
      id: '60',
      name: 'Chicken Shanghai Style',
      category: 'AYAM FILLET',
      price: 120000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
    ),
    MenuItem(
      id: '61',
      name: 'US Beef in Teriyaki Sauce',
      category: 'BEEF',
      price: 125000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 125000),
      ],
    ),
    MenuItem(
      id: '62',
      name: 'US Beef in Black Pepper Sauce',
      category: 'BEEF',
      price: 125000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 125000),
      ],
    ),
    MenuItem(
      id: '63',
      name: 'Kepah Saus Padang',
      category: 'KEPAH',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 70000),
      ],
    ),
    MenuItem(
      id: '64',
      name: 'Kepah Saus Tauco',
      category: 'KEPAH',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 70000),
      ],
    ),
    MenuItem(
      id: '65',
      name: 'Kepah Lada Hitam',
      category: 'KEPAH',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 70000),
      ],
    ),
    MenuItem(
      id: '66',
      name: 'Cumi Saus Tauco',
      category: 'CUMI-CUMI',
      price: 80000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi M'),
        MenuVariant(label: 'Porsi L', extraPrice: 70000),
      ],
    ),
    MenuItem(
      id: '67',
      name: 'Cumi Salted Egg',
      category: 'CUMI-CUMI',
      price: 100000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 50000),
      ],
    ),
    MenuItem(
      id: '68',
      name: 'Cumi Goreng Spesial',
      category: 'CUMI-CUMI',
      price: 70000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 55000),
      ],
    ),
    MenuItem(
      id: '69',
      name: 'Buncis Tumis Ebi',
      category: 'SAYURAN',
      price: 50000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 30000),
      ],
    ),
    MenuItem(
      id: '70',
      name: 'Poileng Tauki Saus Jamur',
      category: 'SAYURAN',
      price: 60000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 40000),
      ],
    ),
    MenuItem(
      id: '71',
      name: 'Brokoli Scallop X.O',
      category: 'SAYURAN',
      price: 80000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 45000),
      ],
    ),
    MenuItem(
      id: '72',
      name: 'Brokoli Udang Saus Kepiting',
      category: 'SAYURAN',
      price: 70000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 30000),
      ],
    ),
    MenuItem(
      id: '73',
      name: 'CimCo Saus Kepiting',
      category: 'SAYURAN',
      price: 60000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi M', extraPrice: 20000),
        MenuVariant(label: 'Porsi L', extraPrice: 50000),
      ],
    ),
    MenuItem(
      id: '74',
      name: 'Brokoli Bebek Asap',
      category: 'SAYURAN',
      price: 80000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 45000),
      ],
    ),
    MenuItem(
      id: '75',
      name: 'Brokoli Salted Egg',
      category: 'SAYURAN',
      price: 125000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '76',
      name: 'Romaine Saus Abalone',
      category: 'SAYURAN',
      price: 100000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '77',
      name: 'Braised Tofu with Mushroom',
      category: 'SAYURAN',
      price: 80000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
      favorite: true,
    ),
    MenuItem(
      id: '78',
      name: 'Bao Cai Chicken / Beef',
      category: 'SAYURAN',
      price: 80000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '79',
      name: 'Tauge Ikan Asin',
      category: 'SAYURAN',
      price: 60000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '80',
      name: 'Omelette Penang Style',
      category: 'SAYURAN',
      price: 70000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '81',
      name: 'Brokoli Siram Telur',
      category: 'SAYURAN',
      price: 50000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 30000),
      ],
    ),
    MenuItem(
      id: '82',
      name: 'Lettuce Abon Ayam',
      category: 'SAYURAN',
      price: 50000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 30000),
      ],
    ),
    MenuItem(
      id: '83',
      name: 'Fu Yung Hai',
      category: 'SAYURAN',
      price: 50000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 30000),
      ],
    ),
    MenuItem(
      id: '84',
      name: 'KauFu Szechuan',
      category: 'TOFU / TAHU',
      price: 50000,
      icon: Icons.lunch_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 30000),
      ],
    ),
    MenuItem(
      id: '85',
      name: 'Skin Tofu Black Pepper',
      category: 'TOFU / TAHU',
      price: 50000,
      icon: Icons.lunch_dining_rounded,
      color: AppColors.primary,
      variants: const [
        MenuVariant(label: 'Porsi S'),
        MenuVariant(label: 'Porsi L', extraPrice: 30000),
      ],
    ),
    MenuItem(
      id: '86',
      name: 'Tahu Bumbu Bawang',
      category: 'TOFU / TAHU',
      price: 50000,
      icon: Icons.lunch_dining_rounded,
      color: AppColors.primary,
      favorite: true,
    ),
    MenuItem(
      id: '87',
      name: 'Mapo Tofu',
      category: 'TOFU / TAHU',
      price: 80000,
      icon: Icons.lunch_dining_rounded,
      color: AppColors.primary,
    ),
    MenuItem(
      id: '88',
      name: 'Tofu Siram Daging',
      category: 'TOFU / TAHU',
      price: 100000,
      icon: Icons.lunch_dining_rounded,
      color: AppColors.primary,
    ),
    MenuItem(
      id: '89',
      name: 'Collagen Soup',
      category: 'BEST SELLER',
      price: 35000,
      icon: Icons.star_rounded,
      color: AppColors.primary,
      description: 'Rp 350/gram (Porsi gramasi hotpot)',
      favorite: true,
      variants: const [
        MenuVariant(label: '100 gram'),
        MenuVariant(label: '200 gram', extraPrice: 35000),
        MenuVariant(label: '300 gram', extraPrice: 70000),
        MenuVariant(label: '500 gram', extraPrice: 140000),
      ],
    ),
    MenuItem(
      id: '90',
      name: 'Mala Stir Fried / Mala Xiang Guo',
      category: 'BEST SELLER',
      price: 35000,
      icon: Icons.star_rounded,
      color: AppColors.primary,
      description: 'Rp 350/gram (Porsi gramasi hotpot)',
      favorite: true,
      variants: const [
        MenuVariant(label: '100 gram'),
        MenuVariant(label: '200 gram', extraPrice: 35000),
        MenuVariant(label: '300 gram', extraPrice: 70000),
        MenuVariant(label: '500 gram', extraPrice: 140000),
      ],
    ),
    MenuItem(
      id: '91',
      name: 'Mala Collagen Soup',
      category: 'BEST SELLER',
      price: 35000,
      icon: Icons.star_rounded,
      color: AppColors.primary,
      description: 'Rp 350/gram (Porsi gramasi hotpot)',
      favorite: true,
      variants: const [
        MenuVariant(label: '100 gram'),
        MenuVariant(label: '200 gram', extraPrice: 35000),
        MenuVariant(label: '300 gram', extraPrice: 70000),
        MenuVariant(label: '500 gram', extraPrice: 140000),
      ],
    ),
    MenuItem(
      id: '92',
      name: 'Mie Ulang Tahun',
      category: 'OTHER',
      price: 150000,
      icon: Icons.ramen_dining_rounded,
      color: AppColors.primary,
    ),
    MenuItem(
      id: '93',
      name: 'Mie Goreng Legend',
      category: 'OTHER',
      price: 35000,
      icon: Icons.ramen_dining_rounded,
      color: AppColors.primary,
      assetPath: AppAssets.heroMieGorengSpecial,
      description: 'Rp 350/gram (Porsi gramasi hotpot)',
      variants: const [
        MenuVariant(label: '100 gram'),
        MenuVariant(label: '200 gram', extraPrice: 35000),
        MenuVariant(label: '300 gram', extraPrice: 70000),
        MenuVariant(label: '500 gram', extraPrice: 140000),
      ],
    ),
    MenuItem(
      id: '94',
      name: 'Nasi Goreng Seafood',
      category: 'OTHER',
      price: 60000,
      icon: Icons.ramen_dining_rounded,
      color: AppColors.primary,
      assetPath: AppAssets.cartNasiGorengSeafood,
    ),
    MenuItem(
      id: '95',
      name: 'Nasi Goreng Ayam',
      category: 'OTHER',
      price: 50000,
      icon: Icons.ramen_dining_rounded,
      color: AppColors.primary,
      assetPath: AppAssets.nasiGoreng,
    ),
    MenuItem(
      id: '96',
      name: 'Nasi Goreng Telur',
      category: 'OTHER',
      price: 40000,
      icon: Icons.ramen_dining_rounded,
      color: AppColors.primary,
      assetPath: AppAssets.nasiGoreng,
    ),
    MenuItem(
      id: '97',
      name: 'Pisang Goreng Crispy',
      category: 'SNACK',
      price: 35000,
      icon: Icons.fastfood_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '98',
      name: 'Kentang Goreng',
      category: 'SNACK',
      price: 25000,
      icon: Icons.fastfood_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '99',
      name: 'Mantho Ayam Kecap',
      category: 'SNACK',
      price: 25000,
      icon: Icons.fastfood_rounded,
      color: AppColors.accentGold,
      description: 'Harga per pc',
    ),
    MenuItem(
      id: '100',
      name: 'Chicken Nugget',
      category: 'SNACK',
      price: 25000,
      icon: Icons.fastfood_rounded,
      color: AppColors.accentGold,
      favorite: true,
    ),
    MenuItem(
      id: '101',
      name: 'Beef Nugget',
      category: 'SNACK',
      price: 30000,
      icon: Icons.fastfood_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '102',
      name: 'Ikan Asam Manis Vegetarian',
      category: 'VEGETARIAN',
      price: 150000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '103',
      name: 'Braised Tofu Vegetarian',
      category: 'VEGETARIAN',
      price: 80000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '104',
      name: 'Angsio Kombinasi Vegetarian',
      category: 'VEGETARIAN',
      price: 80000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '105',
      name: 'Brokoli Salted Egg Vegetarian',
      category: 'VEGETARIAN',
      price: 125000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '106',
      name: 'Mapo Tofu Vegetarian',
      category: 'VEGETARIAN',
      price: 70000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '107',
      name: 'Bebek Curry Vegetarian',
      category: 'VEGETARIAN',
      price: 175000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '108',
      name: 'Paikut Korean Style Vegetarian',
      category: 'VEGETARIAN',
      price: 100000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '109',
      name: 'Curry Kambing Vegetarian',
      category: 'VEGETARIAN',
      price: 175000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '110',
      name: 'Loh Tu Huan Vegetarian',
      category: 'VEGETARIAN',
      price: 175000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '111',
      name: 'Omelette Penang Style Vegetarian',
      category: 'VEGETARIAN',
      price: 70000,
      icon: Icons.eco_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '112',
      name: 'Manggo Lychee',
      category: 'MINUMAN - HOME MADE',
      price: 25000,
      icon: Icons.local_drink_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '113',
      name: 'Wintermelon / Kundur',
      category: 'MINUMAN - HOME MADE',
      price: 25000,
      icon: Icons.local_drink_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '114',
      name: 'Juice Semboi',
      category: 'MINUMAN - HOME MADE',
      price: 25000,
      icon: Icons.local_drink_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '115',
      name: 'Teh Markisa',
      category: 'MINUMAN - HOME MADE',
      price: 25000,
      icon: Icons.local_drink_rounded,
      color: AppColors.accentGold,
      favorite: true,
    ),
    MenuItem(
      id: '116',
      name: 'Juice Jeruk Kesturi / Kiet Na',
      category: 'MINUMAN - HOME MADE',
      price: 25000,
      icon: Icons.local_drink_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '117',
      name: 'Teh Tawar (Hot / Ice)',
      category: 'MINUMAN - TEH / TEA',
      price: 10000,
      icon: Icons.emoji_food_beverage_rounded,
      color: AppColors.accentGold,
      variants: const [
        MenuVariant(label: 'Hot'),
        MenuVariant(label: 'Ice', extraPrice: 2000),
      ],
    ),
    MenuItem(
      id: '118',
      name: 'Teh Manis (Hot / Ice)',
      category: 'MINUMAN - TEH / TEA',
      price: 10000,
      icon: Icons.emoji_food_beverage_rounded,
      color: AppColors.accentGold,
      variants: const [
        MenuVariant(label: 'Hot'),
        MenuVariant(label: 'Ice', extraPrice: 2000),
      ],
    ),
    MenuItem(
      id: '119',
      name: 'Ice Lemon Tea',
      category: 'MINUMAN - TEH / TEA',
      price: 15000,
      icon: Icons.emoji_food_beverage_rounded,
      color: AppColors.accentGold,
      variants: const [
        MenuVariant(label: 'Hot'),
        MenuVariant(label: 'Ice', extraPrice: 3000),
      ],
    ),
    MenuItem(
      id: '120',
      name: 'Ice Lychee Tea',
      category: 'MINUMAN - TEH / TEA',
      price: 25000,
      icon: Icons.emoji_food_beverage_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '121',
      name: 'Chinese Tea (2-5 pax)',
      category: 'MINUMAN - TEH / TEA',
      price: 25000,
      icon: Icons.emoji_food_beverage_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '122',
      name: 'Chinese Tea (6-10 pax)',
      category: 'MINUMAN - TEH / TEA',
      price: 45000,
      icon: Icons.emoji_food_beverage_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '123',
      name: 'Black Coffee (Hot / Ice)',
      category: 'MINUMAN - COFFEE',
      price: 30000,
      icon: Icons.coffee_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '124',
      name: 'Milk Coffee (Hot / Ice)',
      category: 'MINUMAN - COFFEE',
      price: 35000,
      icon: Icons.coffee_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '125',
      name: 'Mineral Water',
      category: 'MINUMAN - BOTTLE / CAN',
      price: 18000,
      icon: Icons.local_drink_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '126',
      name: 'Badak',
      category: 'MINUMAN - BOTTLE / CAN',
      price: 20000,
      icon: Icons.local_drink_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '127',
      name: 'Green Tea',
      category: 'MINUMAN - BOTTLE / CAN',
      price: 18000,
      icon: Icons.local_drink_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '128',
      name: 'Chrysanthemum Tea',
      category: 'MINUMAN - BOTTLE / CAN',
      price: 20000,
      icon: Icons.local_drink_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '129',
      name: 'Wang Lo Kat Tea',
      category: 'MINUMAN - BOTTLE / CAN',
      price: 28000,
      icon: Icons.local_drink_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '130',
      name: 'Bir Bintang Kaleng (Kecil)',
      category: 'MINUMAN - BEER',
      price: 38000,
      icon: Icons.sports_bar_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '131',
      name: 'Bir Bintang Botol (Besar)',
      category: 'MINUMAN - BEER',
      price: 58000,
      icon: Icons.sports_bar_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '132',
      name: 'Bir Heineken Kaleng (Kecil)',
      category: 'MINUMAN - BEER',
      price: 45000,
      icon: Icons.sports_bar_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '133',
      name: 'Bir Heineken Botol (Besar)',
      category: 'MINUMAN - BEER',
      price: 68000,
      icon: Icons.sports_bar_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '134',
      name: 'Bir Guinness Kaleng (Kecil)',
      category: 'MINUMAN - BEER',
      price: 45000,
      icon: Icons.sports_bar_rounded,
      color: AppColors.accentGold,
    ),
    MenuItem(
      id: '135',
      name: 'Bir Guinness Botol (Besar)',
      category: 'MINUMAN - BEER',
      price: 68000,
      icon: Icons.sports_bar_rounded,
      color: AppColors.accentGold,
    ),
  ];

  void _seedTables() {
    tables
      ..clear()
      ..addAll(
        List.generate(
          12,
          (index) => CafeTable(number: index + 1, seats: index % 3 == 0 ? 4 : 2),
        ),
      );
    reservedTables.clear();
    if (seedDemoData) {
      reservedTables.addAll({4: '19:00', 11: '20:00'});
    }
  }

  void _seedInitialData() {
    transactions.clear();
    // Data historis Jan 2025 – Sep 2026 menggunakan menu asli dari store
    transactions.addAll(generateHistoricalTransactions(menu));
    // Data transaksi hari ini (disisipkan di depan)
    transactions.insertAll(0, generateInitialTransactions());
    pendingOrders.clear();
    pendingOrders.addAll(generateInitialPendingOrders(menu));
  }

  int get todaySales {
    if (transactions.isEmpty) return 0;
    final now = DateTime.now();
    final todayTrx = transactions.where((t) =>
      t.createdAt.year == now.year &&
      t.createdAt.month == now.month &&
      t.createdAt.day == now.day,
    );
    if (todayTrx.isNotEmpty) {
      return todayTrx.fold<int>(0, (sum, t) => sum + t.total);
    }
    return 0;
  }

  int get todayTransactions {
    if (transactions.isEmpty) return 0;
    final now = DateTime.now();
    final todayTrx = transactions.where((t) =>
      t.createdAt.year == now.year &&
      t.createdAt.month == now.month &&
      t.createdAt.day == now.day,
    );
    if (todayTrx.isNotEmpty) {
      return todayTrx.length;
    }
    return 0;
  }

  int get cartCount => cart.values.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => cart.values.fold(0, (sum, line) => sum + line.total);
  int get taxableBase => (subtotal - discount).clamp(0, subtotal);
  int get tax => (taxableBase * taxRate).round();
  int get total => taxableBase + tax;

  int get averageTransaction =>
      todayTransactions == 0 ? 0 : (todaySales / todayTransactions).round();
  int get estimatedProfit => (todaySales * .4).round();

  Set<int> get occupiedTables => pendingOrders.keys
      .where((label) => label.startsWith('Meja '))
      .map((label) => int.tryParse(label.replaceAll(RegExp(r'[^0-9]'), '')))
      .whereType<int>()
      .toSet();

  TableStatus statusOf(int tableNumber) {
    if (occupiedTables.contains(tableNumber)) return TableStatus.occupied;
    if (reservedTables.containsKey(tableNumber)) return TableStatus.reserved;
    return TableStatus.free;
  }

  List<String> get categories {
    final values = menu.map((item) => item.category).toSet().toList()..sort();
    return ['Semua', ...values];
  }

  List<MenuItem> get favorites =>
      menu.where((item) => item.favorite).toList(growable: false);

  void setRole(String value) {
    role = value;
    notifyListeners();
  }

  void setDiscount(int value) {
    discount = value.clamp(0, subtotal);
    notifyListeners();
  }

  void startOrder(String label) {
    activeOrder = label;
    discount = 0;
    cart.clear();
    final pending = pendingOrders[label];
    if (pending != null) {
      for (final entry in pending.items.entries) {
        cart[entry.key] = entry.value.clone();
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
        for (final entry in cart.entries) entry.key: entry.value.clone(),
      },
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );
    cart.clear();
    discount = 0;
    activeOrder = null;
    notifyListeners();
  }

  void addItem(
    MenuItem item, {
    String variantLabel = '',
    int variantExtraPrice = 0,
    int quantity = 1,
    String note = '',
  }) {
    if (quantity <= 0) return;
    final key = CartLine.buildKey(item.id, variantLabel);
    final existing = cart[key];
    if (existing == null) {
      cart[key] = CartLine(
        item: item,
        quantity: quantity,
        variantLabel: variantLabel,
        variantExtraPrice: variantExtraPrice,
        note: note,
      );
    } else {
      existing.quantity += quantity;
      if (note.isNotEmpty) existing.note = note;
    }
    notifyListeners();
  }

  void add(MenuItem item) => addItem(item);

  void incrementLine(String key) {
    final line = cart[key];
    if (line == null) return;
    line.quantity++;
    notifyListeners();
  }

  void decrementLine(String key) {
    final line = cart[key];
    if (line == null) return;
    line.quantity--;
    if (line.quantity <= 0) cart.remove(key);
    if (discount > subtotal) discount = subtotal;
    notifyListeners();
  }

  void removeLine(String key) {
    cart.remove(key);
    if (discount > subtotal) discount = subtotal;
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    discount = 0;
    notifyListeners();
  }

  void addProduct({
    required String name,
    required String category,
    required int price,
    String? imagePath,
    String description = '',
    List<MenuVariant>? variants,
  }) {
    menu.add(
      MenuItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        category: category.trim(),
        price: price,
        icon: Icons.restaurant_menu_rounded,
        color: AppColors.primary,
        imagePath: imagePath,
        description: description.trim(),
        variants: variants ??
            const [
              MenuVariant(label: 'Original'),
              MenuVariant(label: 'Pedas'),
            ],
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
    String? description,
    List<MenuVariant>? variants,
    bool clearImagePath = false,
  }) {
    final index = menu.indexWhere((item) => item.id == current.id);
    if (index < 0) return;
    menu[index] = current.copyWith(
      name: name.trim(),
      category: category.trim(),
      price: price,
      imagePath: imagePath,
      description: description?.trim(),
      variants: variants ?? current.variants,
      clearImagePath: clearImagePath,
    );
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = menu.indexWhere((item) => item.id == id);
    if (index < 0) return;
    menu[index] = menu[index].copyWith(favorite: !menu[index].favorite);
    notifyListeners();
  }

  void deleteProduct(String id) {
    menu.removeWhere((item) => item.id == id);
    cart.removeWhere((_, line) => line.item.id == id);
    notifyListeners();
  }

  int get nextTableNumber => tables.isEmpty
      ? 1
      : tables.map((table) => table.number).reduce((a, b) => a > b ? a : b) + 1;

  void addTable({required int seats, int? number, String? reservedUntil}) {
    final targetNumber = number ?? nextTableNumber;
    final existingIndex = tables.indexWhere((t) => t.number == targetNumber);
    final newTable = CafeTable(
      number: targetNumber,
      seats: seats,
      reservedUntil: reservedUntil,
    );

    if (existingIndex >= 0) {
      tables[existingIndex] = newTable;
    } else {
      tables.add(newTable);
      tables.sort((a, b) => a.number.compareTo(b.number));
    }

    if (reservedUntil != null && reservedUntil.trim().isNotEmpty) {
      reservedTables[targetNumber] = reservedUntil.trim();
    } else {
      reservedTables.remove(targetNumber);
    }
    notifyListeners();
  }

  bool deleteTable(int number) {
    if (occupiedTables.contains(number)) return false;
    tables.removeWhere((table) => table.number == number);
    reservedTables.remove(number);
    notifyListeners();
    return true;
  }

  SaleRecord? completeOrder(String paymentMethod, {int? paidAmount}) {
    if (cart.isEmpty) return null;
    final now = DateTime.now();
    final grandTotal = total;
    final transaction = SaleRecord(
      id: 'TRX-${now.millisecondsSinceEpoch}',
      orderLabel: activeOrder ?? 'Take Away',
      items: cart.values
          .map(
            (line) => SaleItemRecord(
              productName: line.displayName,
              quantity: line.quantity,
              unitPrice: line.unitPrice,
            ),
          )
          .toList(),
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: grandTotal,
      paymentMethod: paymentMethod,
      paidAmount: paidAmount ?? grandTotal,
      cashier: currentUsername,
      createdAt: now,
    );

    // Kurangi stok barang sesuai item terjual
    for (final line in cart.values) {
      addStock(line.item.id, -line.quantity);
    }

    transactions.insert(0, transaction);
    if (activeOrder != null) {
      pendingOrders.remove(activeOrder);
      final tableNumber = int.tryParse(
        activeOrder!.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (activeOrder!.startsWith('Meja ') && tableNumber != null) {
        reservedTables.remove(tableNumber);
      }
    }
    cart.clear();
    discount = 0;
    activeOrder = null;
    notifyListeners();
    return transaction;
  }

  int importTransactions(List<SaleRecord> newRecords) {
    if (newRecords.isEmpty) return 0;
    var importedCount = 0;
    for (final rec in newRecords) {
      final idx = transactions.indexWhere((t) => t.id == rec.id);
      if (idx >= 0) {
        transactions[idx] = rec;
      } else {
        transactions.add(rec);
        importedCount++;
      }
    }
    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
    return importedCount > 0 ? importedCount : newRecords.length;
  }

  /// Update field tertentu pada transaksi yang sudah selesai.
  bool updateTransaction(String id, SaleRecord updated) {
    final idx = transactions.indexWhere((t) => t.id == id);
    if (idx < 0) return false;
    transactions[idx] = updated;
    notifyListeners();
    return true;
  }

  /// Hapus transaksi berdasarkan id. Kembalikan true jika berhasil.
  bool deleteTransaction(String id) {
    final before = transactions.length;
    transactions.removeWhere((t) => t.id == id);
    if (transactions.length == before) return false;
    notifyListeners();
    return true;
  }
}
