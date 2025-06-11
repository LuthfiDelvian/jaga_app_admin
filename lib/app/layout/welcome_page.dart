import 'package:flutter/material.dart';
import 'package:jaga_app_admin/app/pages/auth/page/login_register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.jpeg', fit: BoxFit.cover),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset('assets/images/jaga-icon.png', height: 150),
              const SizedBox(height: 20),
              const Text(
                "WELCOME TO JAGA",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Smart Reporting Starts Here.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginRegisterPage(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.arrow_forward,
                  size: 28,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}
