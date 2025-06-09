import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaga_app_admin/app/pages/dashboard/laporan/filtered_laporan_page.dart';
import 'package:jaga_app_admin/app/pages/dashboard/widgets/filter_drawer.dart';
import 'package:jaga_app_admin/app/pages/dashboard/widgets/status_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

Future<Map<String, int>> fetchStatusCounts() async {
  final snapshot = await FirebaseFirestore.instance.collection('laporan').get();
  final docs = snapshot.docs;

  int masuk = 0;
  int terverifikasi = 0;
  int ditolak = 0;

  for (var doc in docs) {
    final data = doc.data();
    final status = (data['status'] ?? '').toString().toLowerCase();

    if (status == 'menunggu') {
      masuk++;
    } else if (status == 'diproses' || status == 'selesai') {
      terverifikasi++;
    } else if (status == 'ditolak') {
      ditolak++;
    }
  }

  return {
    'menunggu': masuk,
    'terverifikasi': terverifikasi,
    'ditolak': ditolak,
  };
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          FutureBuilder<Map<String, int>>(
            future: fetchStatusCounts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final counts =
                  snapshot.data ??
                  {'menunggu': 0, 'terverifikasi': 0, 'ditolak': 0};

              return Row(
                children: [
                  buildStatusCard(
                    '${counts['menunggu']}',
                    'Masuk',
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const FilteredLaporanPage(
                                statusList: ['Menunggu'],
                                title: 'Laporan Masuk',
                              ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  buildStatusCard(
                    '${counts['terverifikasi']}',
                    'Terverifikasi',
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const FilteredLaporanPage(
                                statusList: ['diproses', 'selesai'],
                                title: 'Laporan Terverifikasi',
                              ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  buildStatusCard(
                    '${counts['ditolak']}',
                    'Laporan Ditolak',
                    Colors.red,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const FilteredLaporanPage(
                                statusList: ['ditolak'],
                                title: 'Laporan Ditolak',
                              ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
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
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('laporan') // Ganti dengan nama koleksi kamu
                      .orderBy('tanggal', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Tidak ada laporan.'));
                }

                final laporanList = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: laporanList.length,
                  itemBuilder: (context, index) {
                    final laporan = laporanList[index];
                    final data = laporan.data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        title: Text('${laporan.id}'),

                        subtitle: Text('${data['judul']}'),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              data['tanggal'] is Timestamp
                                  ? (data['tanggal'] as Timestamp)
                                      .toDate()
                                      .toString()
                                      .split(' ')[0]
                                  : data['tanggal'] ?? '',
                            ),
                            const SizedBox(height: 4),
                            buildStatusChip('${data['status']}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
