import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaga_app_admin/app/pages/articles/articles_page.dart';
import 'package:jaga_app_admin/app/pages/laporan/page/filtered_laporan_page.dart';
import 'package:jaga_app_admin/app/pages/laporan/widgets/laporan_bar_chart.dart';
import 'package:jaga_app_admin/app/pages/laporan/widgets/laporan_donut_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _handleTap(BuildContext context, String label) {
    if (label == 'Masuk') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FilteredLaporanPage(
            statusList: ['Menunggu'],
            title: 'Laporan Masuk',
          ),
        ),
      );
    } else if (label == 'Terverifikasi') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FilteredLaporanPage(
            statusList: ['Diproses', 'Selesai'],
            title: 'Laporan Terverifikasi',
          ),
        ),
      );
    } else if (label == 'Ditolak') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FilteredLaporanPage(
            statusList: ['Ditolak'],
            title: 'Laporan Ditolak',
          ),
        ),
      );
    } else if (label == 'Artikel') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ArticlesPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardData = [
      {'label': 'Masuk', 'color': Colors.blue},
      {'label': 'Terverifikasi', 'color': Colors.green},
      {'label': 'Ditolak', 'color': Colors.red},
      {'label': 'Artikel', 'color': Colors.orange},
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: cardData.map((data) {
                  return Material(
                    color: data['color'] as Color,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _handleTap(context, data['label'] as String),
                      child: Center(
                        child: Text(
                          data['label'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 26),

              // Tambahkan donut chart & barchart
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('laporan').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  int masuk = 0;
                  int terverifikasi = 0;
                  int ditolak = 0;
                  DateTime? firstDate;
                  for (final doc in docs) {
                    final data = doc.data();
                    final tgl = data['createdAt'];
                    if (tgl is Timestamp) {
                      final dt = tgl.toDate();
                      if (firstDate == null || dt.isBefore(firstDate)) {
                        firstDate = dt;
                      }
                    }
                    final status = (data['status'] ?? '').toString().toLowerCase();
                    if (status == 'menunggu') {
                      masuk++;
                    } else if (status == 'diproses' || status == 'selesai') {
                      terverifikasi++;
                    } else if (status == 'ditolak') {
                      ditolak++;
                    }
                  }
                  return Column(
                    children: [
                      LaporanDonutChart(
                        masuk: masuk,
                        terverifikasi: terverifikasi,
                        ditolak: ditolak,
                        firstDate: firstDate,
                      ),
                      const SizedBox(height: 22),
                      const LaporanBarChart(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}