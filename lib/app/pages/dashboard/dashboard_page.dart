import 'package:flutter/material.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final laporanList = [
    {
      'id': '12345',
      'judul': 'Dugaan Korupsi Dana Desa',
      'tanggal': '23 Apr 2024',
      'status': 'Masuk',
    },
    {
      'id': '12346',
      'judul': 'Penyalahgunaan Dana Sosial',
      'tanggal': '23 Apr 2024',
      'status': 'Terverifikasi',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: buildMainDrawer(),
      appBar: AppBar(
        title: const Text('JAGA'),
        centerTitle: true,
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatusCard('123', 'Laporan Masuk', Colors.blue),
                const SizedBox(width: 8),
                _buildStatusCard('45', 'Terverifikasi', Colors.green),
                const SizedBox(width: 8),
                _buildStatusCard('34', 'Ditolak', Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Daftar Laporan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt),
                  onPressed: () => showFilterDrawer(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: laporanList.length,
                itemBuilder: (context, index) {
                  final laporan = laporanList[index];
                  return Card(
                    child: ListTile(
                      title: Text('Laporan #${laporan['id']}'),
                      subtitle: Text('${laporan['judul']}'),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${laporan['tanggal']}'),
                          const SizedBox(height: 4),
                          _buildStatusChip('${laporan['status']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String jumlah, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              jumlah,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Terverifikasi':
        color = Colors.green;
        break;
      case 'Ditolak':
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status, style: TextStyle(color: color)),
    );
  }

  void showFilterDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filter',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filter Laporan",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text("Jenis Laporan"),
                    DropdownButtonFormField(
                      items: const [
                        DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                        DropdownMenuItem(
                          value: 'Pengaduan',
                          child: Text('Pengaduan'),
                        ),
                        DropdownMenuItem(
                          value: 'Aspirasi',
                          child: Text('Aspirasi'),
                        ),
                      ],
                      onChanged: (_) {},
                      value: 'Semua',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Tanggal"),
                    DropdownButtonFormField(
                      items: const [
                        DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                        DropdownMenuItem(
                          value: 'Terbaru',
                          child: Text('Terbaru'),
                        ),
                        DropdownMenuItem(
                          value: 'Terlama',
                          child: Text('Terlama'),
                        ),
                      ],
                      onChanged: (_) {},
                      value: 'Semua',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("Urutkan"),
                    RadioListTile(
                      title: const Text("Status"),
                      value: 'status',
                      groupValue: 'status',
                      onChanged: (_) {},
                    ),
                    RadioListTile(
                      title: const Text("Tanggal"),
                      value: 'tanggal',
                      groupValue: 'status',
                      onChanged: (_) {},
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Hapus"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Terapkan filter di sini
                          },
                          child: const Text("Terapkan"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  Drawer buildMainDrawer() {
    return Drawer(
      child: Container(
        color: Colors.red[600],
        padding: const EdgeInsets.only(top: 60, left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'JAGA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            drawerItem('Dashboard', selected: true),
            const SizedBox(height: 16),
            drawerItem('Laporan Masuk'),
            const SizedBox(height: 16),
            drawerItem('Artikel'),
            const SizedBox(height: 16),
            drawerItem('Pengaturan'),
          ],
        ),
      ),
    );
  }

  Widget drawerItem(String title, {bool selected = false}) {
    return Container(
      color: selected ? Colors.red[800] : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
