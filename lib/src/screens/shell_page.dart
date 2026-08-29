import 'package:flutter/material.dart';

import '../pos_store.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int index = 0;
  static const labels = [
    'Beranda',
    'Pesanan',
    'Transaksi',
    'Produk',
    'Laporan',
    'Pengaturan',
  ];
  static const icons = [
    Icons.grid_view_rounded,
    Icons.table_restaurant_rounded,
    Icons.receipt_long_rounded,
    Icons.local_cafe_rounded,
    Icons.bar_chart_rounded,
    Icons.settings_rounded,
  ];

  void openTables() => setState(() => index = 1);

  void logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginPage(store: widget.store)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(store: widget.store, onNewOrder: openTables),
      TablePage(store: widget.store),
      TransactionPage(store: widget.store),
      ProductPage(store: widget.store),
      ReportPage(store: widget.store),
      SimpleListPage(
        title: 'Pengaturan',
        subtitle: 'Atur cafe, pajak, dan pembayaran',
        icon: Icons.settings_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        final content = AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(key: ValueKey(index), child: pages[index]),
        );
        if (!desktop) {
          const mobileIndices = [0, 1, 3, 4, -1];
          final mobileSelected = mobileIndices.indexOf(index);
          return Scaffold(
            key: _scaffoldKey,
            body: SafeArea(child: content),
            drawer: Drawer(
              child: SafeArea(
                child: ListView(
                  children: [
                    ...List.generate(
                      labels.length,
                      (i) => ListTile(
                        leading: Icon(icons[i]),
                        title: Text(labels[i]),
                        selected: index == i,
                        onTap: () {
                          setState(() => index = i);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded),
                      title: const Text('Logout'),
                      onTap: logout,
                    ),
                  ],
                ),
              ),
            ),
            appBar: AppBar(
              title: Text(labels[index]),
              actions: [
                IconButton(
                  tooltip: 'Logout',
                  onPressed: logout,
                  icon: const Icon(Icons.logout_rounded),
                ),
                const SizedBox(width: 8),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: mobileSelected < 0 ? 0 : mobileSelected,
              onDestinationSelected: (value) {
                final selected = mobileIndices[value];
                if (selected == -1) {
                  _scaffoldKey.currentState?.openDrawer();
                  return;
                }
                setState(() => index = selected);
              },
              destinations: List.generate(mobileIndices.length, (i) {
                final itemIndex = mobileIndices[i];
                if (itemIndex == -1) {
                  return const NavigationDestination(
                    icon: Icon(Icons.menu_rounded),
                    label: 'Menu',
                  );
                }
                return NavigationDestination(
                  icon: Icon(icons[itemIndex]),
                  label: labels[itemIndex],
                );
              }),
            ),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                Container(
                  width: 210,
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF244D41),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFFEBB36B),
                          child: Icon(
                            Icons.coffee_rounded,
                            color: Color(0xFF244D41),
                          ),
                        ),
                        title: Text(
                          'Simpel POS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(
                        labels.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: ListTile(
                            selected: index == i,
                            selectedTileColor: Colors.white.withValues(
                              alpha: .13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            leading: Icon(
                              icons[i],
                              color: index == i
                                  ? const Color(0xFFF3C37B)
                                  : Colors.white70,
                            ),
                            title: Text(
                              labels[i],
                              style: TextStyle(
                                color: index == i
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: index == i
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            onTap: () => setState(() => index = i),
                          ),
                        ),
                      ),
                      const Spacer(),
                      ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_rounded),
                        ),
                        title: Text(
                          widget.store.role,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: const Text(
                          'Sedang bertugas',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: logout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: .35),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        );
      },
    );
  }
}
