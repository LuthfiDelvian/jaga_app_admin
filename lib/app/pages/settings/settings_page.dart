import 'package:flutter/material.dart';
import 'package:jaga_app_admin/app/auth_service.dart';
import 'package:jaga_app_admin/app/pages/auth/page/login_register_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data user dari Firebase Auth
    final user = authService.value.currentUser;

    // Gunakan dummy jika data kosong
    final String photoUrl = user?.photoURL ?? '';
    final String nama = user?.displayName ?? 'Admin Jaga';
    final String email = user?.email ?? '-';
    final String username = user?.email != null
        ? '@' + (user!.email!.split('@').first)
        : '@username';

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
            child: photoUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(photoUrl, fit: BoxFit.cover, width: 84, height: 84),
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
                // Profil
                ListTile(
                  title: const Text('Profil'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: aksi edit profil
                  },
                  dense: true,
                  shape: const Border(
                    bottom: BorderSide(color: Color(0xFFF2F2F2)),
                  ),
                ),
                // Notifikasi
                ListTile(
                  title: const Text('Kelola Notifikasi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: aksi kelola notifikasi
                  },
                  dense: true,
                  shape: const Border(
                    bottom: BorderSide(color: Color(0xFFF2F2F2)),
                  ),
                ),
                // Bahasa
                ListTile(
                  title: const Text('Bahasa'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: aksi bahasa
                  },
                  dense: true,
                  shape: const Border(
                    bottom: BorderSide(color: Color(0xFFF2F2F2)),
                  ),
                ),
                // Tampilan
                ListTile(
                  title: const Text('Tampilan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: aksi tampilan
                  },
                  dense: true,
                ),
                // Keluar
                const Divider(height: 0, thickness: 1.2),
                ListTile(
                  title: const Text(
                    'Keluar',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await authService.value.signOut();
                      // Setelah logout, redirect ke login/register page
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginRegisterPage()),
                        (route) => false,
                      );
                    }
                  },
                  dense: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}