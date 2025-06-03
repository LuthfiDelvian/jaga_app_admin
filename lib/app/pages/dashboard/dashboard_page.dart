import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaga_app_admin/app/pages/dashboard/widgets/filter_drawer.dart';
import 'package:jaga_app_admin/app/pages/dashboard/widgets/status_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              buildStatusCard('123', 'Laporan Masuk', Colors.blue),
              const SizedBox(width: 8),
              buildStatusCard('45', 'Terverifikasi', Colors.green),
              const SizedBox(width: 8),
              buildStatusCard('34', 'Laporan Ditolak', Colors.red),
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
