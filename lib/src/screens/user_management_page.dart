import 'package:flutter/material.dart';

import '../models.dart';
import '../pos_store.dart';
import '../theme/app_theme.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key, required this.store});

  final PosStore store;

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  Future<void> _openEditCredentialDialog(UserAccount user) async {
    final usernameController = TextEditingController(text: user.username);
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscure = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.vpn_key_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ubah Akun ${user.role}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Owner dapat mengganti username dan password untuk akun peran ${user.role}:',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username Akun',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Username tidak boleh kosong';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          labelText: 'Password Baru',
                          helperText: 'Kosongkan jika password tidak ingin diubah',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          suffixIcon: IconButton(
                            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setDialogState(() => obscure = !obscure),
                          ),
                        ),
                        validator: (val) {
                          if (val != null && val.trim().isNotEmpty && val.trim().length < 3) {
                            return 'Minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(ctx, true);
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true || !mounted) return;

    widget.store.ownerUpdateUserCredentials(
      originalUsername: user.username,
      newUsername: usernameController.text.trim(),
      newPassword: passwordController.text.trim().isEmpty ? null : passwordController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Akun ${user.role} berhasil diperbarui!')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.store.role == 'Owner';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Manajemen Akun Pengguna'),
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
                    'Kelola Kredensial Pengguna',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOwner
                        ? 'Sebagai Owner, Anda berhak mengganti username dan password untuk tiap akun role kasir, admin, staf, maupun owner.'
                        : 'Hanya peran Owner yang memiliki wewenang untuk mengubah username dan password akun.',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...widget.store.users.map((user) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primarySoft,
                        child: Text(
                          user.role[0],
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user.role,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Username: ${user.username}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Password: ${"•" * user.password.length}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      if (isOwner)
                        FilledButton.tonalIcon(
                          onPressed: () => _openEditCredentialDialog(user),
                          icon: const Icon(Icons.vpn_key_rounded, size: 16),
                          label: const Text('Ganti Password'),
                        )
                      else
                        const Chip(label: Text('Read-Only')),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
