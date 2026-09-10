import 'package:flutter/material.dart';

import '../pos_store.dart';
import '../theme/app_theme.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'order_page.dart';
import 'product_page.dart';
import 'report_page.dart';
import 'simple_pages.dart';
import 'table_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key, required this.store});

  final PosStore store;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int currentIndex = 0;

  void _openTables() => setState(() => currentIndex = 1);

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginPage(store: widget.store)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(store: widget.store, onNewOrder: _openTables),
      TablePage(store: widget.store),
      OrderPage(store: widget.store),
      ReportPage(store: widget.store),
      _MoreMenuPage(store: widget.store, onLogout: _logout),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: AdminBackdrop(
          imageOpacity: currentIndex == 0 ? .34 : .28,
          overlayOpacity: currentIndex == 0 ? .48 : .55,
          child: IndexedStack(index: currentIndex, children: pages),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => setState(() => currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_restaurant_outlined),
            selectedIcon: Icon(Icons.table_restaurant_rounded),
            label: 'Meja',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Pesanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Lainnya',
          ),
        ],
      ),
    );
  }
}

class _MoreMenuPage extends StatelessWidget {
  const _MoreMenuPage({required this.store, required this.onLogout});

  final PosStore store;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Image.asset(
              AppAssets.logo,
              width: 44,
              height: 44,
              errorBuilder: (_, _, _) => const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.restaurant, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppBrand.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Peran: ${store.role}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _MenuTile(
          icon: Icons.table_restaurant_rounded,
          title: 'Atur & Kelola Meja',
          subtitle: 'Atur nomor meja, kapasitas kursi, & reservasi',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TableFormPage(store: store)),
            );
          },
        ),
        _MenuTile(
          icon: Icons.inventory_2_outlined,
          title: 'Kelola Produk & Menu',
          subtitle: 'Ubah harga, tambah varian, kelola foto',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProductPage(store: store)),
            );
          },
        ),
        _MenuTile(
          icon: Icons.receipt_outlined,
          title: 'Riwayat Transaksi',
          subtitle: 'Daftar semua transaksi yang telah selesai',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(title: const Text('Riwayat Transaksi')),
                  body: AdminBackdrop(child: TransactionPage(store: store)),
                ),
              ),
            );
          },
        ),
        _MenuTile(
          icon: Icons.settings_outlined,
          title: 'Pengaturan Restoran',
          subtitle: 'Pajak, profil kasir, dan struk',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(title: const Text('Pengaturan')),
                  body: const AdminBackdrop(
                    child: SimpleListPage(
                      title: 'Pengaturan',
                      subtitle: 'Atur restoran, pajak, dan metode pembayaran',
                      icon: Icons.settings_rounded,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
            ),
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Ganti Akun / Keluar'),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textMuted,
        ),
        onTap: onTap,
      ),
    );
  }
}
