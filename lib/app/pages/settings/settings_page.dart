import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jaga_app_admin/app/services/auth_service.dart';
import 'package:jaga_app_admin/app/pages/auth/page/login_register_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedLanguage = 'id';

  @override
  Widget build(BuildContext context) {
    final user = authService.value.currentUser;

    final String photoUrl = user?.photoURL ?? '';
    final String nama = user?.displayName ?? 'Admin Jaga';
    final String email = user?.email ?? '-';
    final String username =
        user?.email != null ? '@${user!.email!.split('@').first}' : '@username';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          const SizedBox(height: 12),
          // Avatar
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.grey.shade300,
            child:
                photoUrl.isNotEmpty
                    ? ClipOval(
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        width: 84,
                        height: 84,
                      ),
                    )
                    : const Icon(Icons.person, color: Colors.white, size: 54),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              nama,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Center(
            child: Text(
              username,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
          const SizedBox(height: 22),
          // Settings Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.07),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Email
                ListTile(
                  title: const Text('Email'),
                  trailing: Text(
                    email,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  dense: true,
                  shape: const Border(
                    bottom: BorderSide(color: Color(0xFFF2F2F2)),
                  ),
                ),
                // Ganti Username
                ListTile(
                  title: const Text('Ganti Username'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangeUsernameDialog(context),
                  dense: true,
                  shape: const Border(
                    bottom: BorderSide(color: Color(0xFFF2F2F2)),
                  ),
                ),
                // Ganti Password
                ListTile(
                  title: const Text('Ganti Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context),
                  dense: true,
                  shape: const Border(
                    bottom: BorderSide(color: Color(0xFFF2F2F2)),
                  ),
                ),
                // Bahasa dengan dialog custom (radio)
                ListTile(
                  title: const Text('Bahasa'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedLanguage == 'id'
                            ? 'Bahasa Indonesia'
                            : 'English',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => _showLanguageDialog(context),
                  dense: true,
                  shape: const Border(
                    bottom: BorderSide(color: Color(0xFFF2F2F2)),
                  ),
                ),
                // Divider & Logout
                const Divider(height: 0, thickness: 1.2),
                ListTile(
                  title: const Text(
                    'Keluar',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Konfirmasi'),
                            content: const Text(
                              'Apakah Anda yakin ingin keluar?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: const Text(
                                  'Keluar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );
                    if (confirm == true) {
                      await authService.value.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const LoginRegisterPage(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  dense: true,
                ),
                // Divider & Hapus Akun
                const Divider(height: 0, thickness: 1.2),
                ListTile(
                  title: const Text(
                    'Hapus Akun',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => _showDeleteAccountDialog(context, email),
                  dense: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==== POPUP GANTI USERNAME ====
  void _showChangeUsernameDialog(BuildContext context) {
    final usernameController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ganti Username'),
            content: TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username baru'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await authService.value.updateUsername(
                      newUsername: usernameController.text.trim(),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Username berhasil diubah')),
                    );
                    setState(() {}); // Refresh tampilan nama jika perlu
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mengubah username: $e')),
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  // ==== POPUP GANTI PASSWORD ====
  void _showChangePasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ganti Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password Saat Ini',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password Baru'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  final currentPassword = currentPasswordController.text;
                  final newPassword = newPasswordController.text;
                  try {
                    // 1. Re-authenticate user
                    final credential = EmailAuthProvider.credential(
                      email: email,
                      password: currentPassword,
                    );
                    await authService.value.currentUser!
                        .reauthenticateWithCredential(credential);
                    // 2. Change password
                    await authService.value.changePassword(
                      newPassword: newPassword,
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password berhasil diubah')),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mengubah password : Email/Password yang anda masukkan salah!')),
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  // ==== POPUP HAPUS AKUN ====
  void _showDeleteAccountDialog(BuildContext context, String email) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Hapus Akun'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Masukkan password untuk konfirmasi hapus akun:'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    onChanged:
                        (_) => setState(() {}), // untuk refresh state tombol
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed:
                      passwordController.text.trim().isEmpty
                          ? null
                          : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Konfirmasi Hapus Akun'),
                                    content: const Text(
                                      'Apakah Anda benar-benar yakin ingin menghapus akun Anda? Tindakan ini tidak bisa dibatalkan.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text(
                                          'Ya, Hapus',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirm == true) {
                              try {
                                await authService.value.deleteAccount(
                                  email: email,
                                  password: passwordController.text.trim(),
                                );
                                Navigator.pop(context); // tutup dialog
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginRegisterPage(),
                                  ),
                                  (route) => false,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Akun berhasil dihapus'),
                                  ),
                                );
                              } catch (e) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Password yang anda masukkan salah',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                  child: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==== POPUP PILIHAN BAHASA ====
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String tempLang = selectedLanguage;
        return AlertDialog(
          title: const Text('Pilih Bahasa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: 'id',
                groupValue: tempLang,
                title: const Text('Bahasa Indonesia'),
                onChanged: (value) {
                  setState(() => selectedLanguage = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                value: 'en',
                groupValue: tempLang,
                title: const Text('English'),
                onChanged: (value) {
                  setState(() => selectedLanguage = value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}
