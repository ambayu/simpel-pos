import 'package:flutter/material.dart';

import '../models.dart';
import '../pos_store.dart';
import '../theme/app_theme.dart';

class RolePermissionsPage extends StatefulWidget {
  const RolePermissionsPage({super.key, required this.store});

  final PosStore store;

  @override
  State<RolePermissionsPage> createState() => _RolePermissionsPageState();
}

class _RolePermissionsPageState extends State<RolePermissionsPage> {
  String selectedRole = 'Kasir';

  static const availableRoles = ['Admin', 'Kasir', 'Pegawai'];

  @override
  Widget build(BuildContext context) {
    final permissions = widget.store.rolePermissions[selectedRole] ?? <SimpelPermission>{};

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Atur Hak Akses & Permission'),
      ),
      body: AdminBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            HeaderCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengaturan Hak Akses Bebas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pilih role di bawah ini untuk mengatur menu mana yang bisa dilihat saja dan aksi mana yang diizinkan untuk dimodifikasi secara bebas.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: availableRoles.map((r) {
                      final isSelected = r == selectedRole;
                      return ChoiceChip(
                        label: Text(r),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => selectedRole = r);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Daftar Izin untuk Role: $selectedRole',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ...SimpelPermission.values.where((p) => p != SimpelPermission.userManagement).map((perm) {
              final isAllowed = permissions.contains(perm);
              final isAction = perm.isAction;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: isAction
                      ? BorderSide(color: AppColors.primary.withValues(alpha: 0.3))
                      : BorderSide.none,
                ),
                child: SwitchListTile(
                  dense: true,
                  title: Row(
                    children: [
                      Icon(
                        isAction ? Icons.touch_app_rounded : Icons.visibility_rounded,
                        size: 18,
                        color: isAction ? AppColors.primary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          perm.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isAction ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    isAction
                        ? 'Izinkan aksi penambahan / pengubahan / penghapusan data'
                        : 'Izinkan membuka dan melihat menu halaman',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  value: isAllowed,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    widget.store.togglePermission(selectedRole, perm, val);
                    setState(() {});
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
