import 'package:flutter/material.dart';
import 'package:jaga_app_admin/app/layout/main_drawer.dart';
import 'package:jaga_app_admin/app/pages/articles/articles_page.dart';
import 'package:jaga_app_admin/app/pages/dashboard/page/dashboard_page.dart';
import 'package:jaga_app_admin/app/pages/laporan/page/laporan_page.dart';
import 'package:jaga_app_admin/app/pages/settings/settings_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    LaporanPage(),
    ArticlesPage(),
    SettingsPage(),
  ];

  void _onSelectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Image.asset('assets/images/jaga-icon.png', color: Colors.white, height: 85,),
        backgroundColor: Colors.red,
      ),
      drawer: MainDrawer(
        selectedIndex: _selectedIndex,
        onSelectPage: _onSelectPage,
      ),
      body: _pages[_selectedIndex],
    );
  }
}
