import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  final void Function(int) onSelectPage;
  final int selectedIndex;

  const MainDrawer({
    super.key,
    required this.onSelectPage,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // Lebar drawer yang lebih kecil (default biasanya ~304)
      child: Drawer(
        child: Container(
          color: Colors.red, // Warna dasar drawer
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                color: Colors.red,
                child: Center(
                  child: Image.asset(
                    'assets/images/jaga-icon.png',
                    color: Colors.white,
                  ),
                ),
              ),
              _buildDrawerItem('Dashboard', 0),
              _buildDrawerItem('Laporan Masuk', 1),
              _buildDrawerItem('Artikel', 2),
              _buildDrawerItem('Pengaturan', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title, int index) {
    final isSelected = selectedIndex == index;

    return Container(
      color: isSelected ? Colors.red[800] : Colors.red,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 24, right: 16),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: () => onSelectPage(index),
      ),
    );
  }
}
