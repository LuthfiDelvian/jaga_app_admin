import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaga_app_admin/app/services/auth_service.dart';

import 'package:jaga_app_admin/app/layout/main_shell.dart';
import 'package:jaga_app_admin/app/pages/auth/page/forgot_password_page.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  // Controllers
  final emailLoginController = TextEditingController();
  final passwordLoginController = TextEditingController();

  final usernameRegisterController = TextEditingController();
  final emailRegisterController = TextEditingController();
  final passwordRegisterController = TextEditingController();
  final confirmPasswordRegisterController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    emailLoginController.dispose();
    passwordLoginController.dispose();
    usernameRegisterController.dispose();
    emailRegisterController.dispose();
    passwordRegisterController.dispose();
    confirmPasswordRegisterController.dispose();
    super.dispose();
  }

  // LOGIN LOGIC
  Future<void> loginAdmin() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await authService.value.signIn(
        email: emailLoginController.text.trim(),
        password: passwordLoginController.text.trim(),
      );
      // Cek role di Firestore
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();
      if (doc.exists && doc.data()?['role'] == 'admin') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login berhasil!')));

        await Future.delayed(const Duration(milliseconds: 1000));

        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
      } else {
        await authService.value.signOut();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Akun ini bukan admin!')));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Email atau password salah!';

      if (e.code == 'invalid-email') {
        errorMessage = 'Format email tidak valid.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // REGISTER LOGIC
  Future<void> registerAdmin() async {
    if (usernameRegisterController.text.trim().isEmpty ||
        emailRegisterController.text.trim().isEmpty ||
        passwordRegisterController.text.isEmpty ||
        confirmPasswordRegisterController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua field!')),
      );
      return;
    }
    if (passwordRegisterController.text !=
        confirmPasswordRegisterController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak sama!')),
      );
      return;
    }
    if (passwordRegisterController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userCredential = await authService.value.createAccount(
        email: emailRegisterController.text.trim(),
        password: passwordRegisterController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'email': emailRegisterController.text.trim(),
            'username': usernameRegisterController.text.trim(),
            'role': 'admin',
            'created_at': FieldValue.serverTimestamp(),
          });

      // Setelah berhasil daftar:
      // 1. Logout user yang baru register (agar tidak auto-login)
      await authService.value.signOut();

      // 2. Bersihkan field register
      usernameRegisterController.clear();
      emailRegisterController.clear();
      passwordRegisterController.clear();
      confirmPasswordRegisterController.clear();

      // 3. Kembali ke tab login
      _tabController.animateTo(0);

      // 4. Tampilkan snackbar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
      );
    } on FirebaseAuthException catch (e) {
      String error = 'Gagal daftar';
      if (e.code == 'email-already-in-use') {
        error = 'Email sudah terdaftar';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // RESET PASSWORD
  Future<void> resetPassword() async {
    if (emailLoginController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan email untuk reset password!')),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailLoginController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link reset dikirim ke email!')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Gagal kirim reset password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/jaga-icon.png', height: 100),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.red,
              labelColor: Colors.red,
              unselectedLabelColor: Colors.black,
              tabs: const [Tab(text: "Masuk"), Tab(text: "Daftar")],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab Masuk
                  SingleChildScrollView(
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            TextField(
                              controller: emailLoginController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: passwordLoginController,
                              obscureText: _hidePassword,
                              decoration: InputDecoration(
                                hintText: 'Kata Sandi',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: GestureDetector(
                                  onTap:
                                      _isLoading
                                          ? null
                                          : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) =>
                                                        const ForgotPasswordPage(),
                                              ),
                                            );
                                          },

                                  child: const Text(
                                    'Lupa kata sandi?',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: _isLoading ? null : loginAdmin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size.fromHeight(45),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        'Masuk',
                                        style: TextStyle(color: Colors.white),
                                      ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Belum punya akun?'),
                                const SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () {
                                    _tabController.animateTo(1);
                                  },
                                  child: const Text(
                                    'Daftar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Tab Daftar
                  SingleChildScrollView(
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            TextField(
                              controller: usernameRegisterController,
                              decoration: const InputDecoration(
                                hintText: 'Username',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: emailRegisterController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: passwordRegisterController,
                              obscureText: _hidePassword,
                              decoration: InputDecoration(
                                hintText: 'Kata sandi',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: confirmPasswordRegisterController,
                              obscureText: _hideConfirmPassword,
                              decoration: InputDecoration(
                                hintText: 'Konfirmasi kata sandi',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _hideConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hideConfirmPassword =
                                          !_hideConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _isLoading ? null : registerAdmin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size.fromHeight(45),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        'Daftar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Sudah punya akun?'),
                                const SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () {
                                    _tabController.animateTo(0);
                                  },
                                  child: const Text(
                                    'Masuk disini',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
