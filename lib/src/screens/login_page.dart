import 'package:flutter/material.dart';

import '../pos_store.dart';
import '../theme/app_theme.dart';
import 'shell_page.dart';

class _RoleOption {
  const _RoleOption({
    required this.name,
    required this.icon,
    required this.assetPath,
    required this.description,
  });

  final String name;
  final IconData icon;
  final String assetPath;
  final String description;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.store});

  final PosStore store;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String selectedRole = 'Kasir';

  static const roles = <_RoleOption>[
    _RoleOption(
      name: 'Owner',
      icon: Icons.workspace_premium_rounded,
      assetPath: AppAssets.roleOwner,
      description: 'Akses penuh semua fitur',
    ),
    _RoleOption(
      name: 'Admin',
      icon: Icons.tune_rounded,
      assetPath: AppAssets.roleAdmin,
      description: 'Kelola operasional dan data',
    ),
    _RoleOption(
      name: 'Kasir',
      icon: Icons.point_of_sale_rounded,
      assetPath: AppAssets.roleCashier,
      description: 'Proses transaksi kasir harian',
    ),
    _RoleOption(
      name: 'Pegawai',
      icon: Icons.room_service_rounded,
      assetPath: AppAssets.roleStaff,
      description: 'Lihat pesanan dan dapur',
    ),
  ];

  void _submit() {
    widget.store.setRole(selectedRole);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ShellPage(store: widget.store)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.chinaLandscape,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: AppColors.background),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                      child: Column(
                        children: [
                          HeaderCard(
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  visualDensity: VisualDensity.compact,
                                ),
                                const Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Pilih Peran Anda',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Masuk sesuai peran untuk melanjutkan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 40),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: roles.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisExtent: isWide ? 230 : 210,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                ),
                            itemBuilder: (context, index) {
                              final role = roles[index];
                              final selected = role.name == selectedRole;
                              return _RoleCard(
                                role: role,
                                selected: selected,
                                onTap: () =>
                                    setState(() => selectedRole = role.name),
                              );
                            },
                          ),
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _submit,
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.chevron_right_rounded),
                            label: Text('Masuk sebagai $selectedRole'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tim yang baik',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Text(
                        'Membuat restoran luar biasa',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  ),
);
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final _RoleOption role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Colors.white.withValues(alpha: .96)
          : Colors.white.withValues(alpha: .86),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(7, 5, 7, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.7 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: selected ? .08 : .04),
                blurRadius: selected ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  role.assetPath,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (_, _, _) =>
                      Icon(role.icon, size: 64, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                role.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                role.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  selected ? Icons.check_rounded : Icons.chevron_right_rounded,
                  size: 14,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
