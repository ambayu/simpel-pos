import 'package:flutter/material.dart';

import '../pos_store.dart';
import 'shell_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.store});

  final PosStore store;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String selectedRole = 'Kasir';

  final roles = const [
    (
      'Kasir',
      Icons.point_of_sale_rounded,
      'Kasir Utama',
      'Input pesanan, cetak struk & bayar',
      Color(0xFF1E5642),
      Color(0xFFE6F4EE),
      'Transaksi',
    ),
    (
      'Pelayan',
      Icons.room_service_rounded,
      'Staff Meja',
      'Pilih meja, catat menu & simpan order',
      Color(0xFFB45309),
      Color(0xFFFEF3C7),
      'Pesanan',
    ),
    (
      'Admin',
      Icons.tune_rounded,
      'Admin Cafe',
      'Kelola menu, harga & master meja',
      Color(0xFF1D4ED8),
      Color(0xFFEFF6FF),
      'Kelola Data',
    ),
    (
      'Owner',
      Icons.auto_graph_rounded,
      'Owner Bisnis',
      'Pantau omzet harian & download Excel',
      Color(0xFF7E22CE),
      Color(0xFFFAF5FF),
      'Laporan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 780;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 5, child: _buildVisualAppShowcase()),
                  Expanded(
                    flex: 6,
                    child: Container(
                      color: const Color(0xFFFFFCF8),
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 44,
                            vertical: 28,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: _buildLoginRolePanel(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildVisualAppShowcase(isCompact: true),
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFFFCF8),
                    child: _buildLoginRolePanel(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // WIDGET SISI KIRI: GAMBAR VISUAL & FITUR APLIKASI KASIR
  Widget _buildVisualAppShowcase({bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A2F), Color(0xFF11241C)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo & Title Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2BD72),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF2BD72).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.coffee_rounded,
                  color: Color(0xFF1E3A2F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simpel POS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Sistem Kasir Sentuh Cepat',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9EBAAE),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Mini Mockup Graphic Card (Ilustrasi Aplikasi Kasir)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.table_restaurant_rounded,
                              size: 12,
                              color: Color(0xFF34D399),
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Meja 05 • Dine In',
                                style: TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Pesanan Aktif',
                      style: TextStyle(
                        color: Color(0xFFF2BD72),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC67C4E).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_cafe_rounded,
                        color: Color(0xFFF2BD72),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2x Kopi Susu Aren',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Pajak 10% • Simpan Bill',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Rp48.400',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Value Proposition
          const Text(
            'Kasir Praktis,\nTanpa Ribet Ketik.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih nomor meja, tap kartu menu untuk memasukkan pesanan, dan bayar nanti saat tamu selesai.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // Feature Badges
          const Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _ShowcaseBadge(
                icon: Icons.touch_app_rounded,
                label: 'Mode Sentuh',
              ),
              _ShowcaseBadge(
                icon: Icons.table_bar_rounded,
                label: 'Visual Meja',
              ),
              _ShowcaseBadge(
                icon: Icons.receipt_long_rounded,
                label: 'Bayar Nanti',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET SISI KANAN: PANEL LOGIN & PILIH ROLE
  Widget _buildLoginRolePanel() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E5642).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: Color(0xFF1E5642),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Pilih Role Petugas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih akun tugas untuk langsung memulai operasional:',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),

          // Role selection list/grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: roles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.65,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final role = roles[index];
              final isSelected = role.$1 == selectedRole;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => selectedRole = role.$1),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? role.$6 : const Color(0xFFFAFAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? role.$5 : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected ? role.$5 : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                role.$2,
                                color: isSelected ? Colors.white : role.$5,
                                size: 14,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: role.$5,
                                size: 16,
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role.$1,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              role.$3,
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Tombol Masuk
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A2F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                widget.store.setRole(selectedRole);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ShellPage(store: widget.store),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(
                'Masuk sebagai $selectedRole',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(
                  Icons.lock_open_rounded,
                  size: 12,
                  color: Color(0xFF94A3B8),
                ),
                Text(
                  'Akses Cepat Sekali Ketuk • Tanpa Password',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowcaseBadge extends StatelessWidget {
  const _ShowcaseBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFF2BD72)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
