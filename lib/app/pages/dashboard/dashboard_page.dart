import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaga_app_admin/app/pages/dashboard/laporan/widgets/laporan_card.dart';
import 'laporan/page/laporan_detail_page.dart';
import 'laporan/page/filtered_laporan_page.dart';
import 'widgets/filter_drawer.dart';
import 'widgets/status_summary.dart';
import 'utils/format_tanggal.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  void handleStatusCardTap(String status) {
    if (status == 'menunggu') {
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
    } else if (status == 'terverifikasi') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => const FilteredLaporanPage(
                statusList: ['Diproses', 'Selesai'],
                title: 'Laporan Terverifikasi',
              ),
        ),
      );
    } else if (status == 'ditolak') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => const FilteredLaporanPage(
                statusList: ['Ditolak'],
                title: 'Laporan Ditolak',
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // STREAMBUILDER UNTUK STATUS SUMMARY (REALTIME)
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('laporan').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              int masuk = 0;
              int terverifikasi = 0;
              int ditolak = 0;

              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final status = (data['status'] ?? '').toString().toLowerCase();

                if (status == 'menunggu') {
                  masuk++;
                } else if (status == 'diproses' || status == 'selesai') {
                  terverifikasi++;
                } else if (status == 'ditolak') {
                  ditolak++;
                }
              }

              final counts = {
                'menunggu': masuk,
                'terverifikasi': terverifikasi,
                'ditolak': ditolak,
              };

              return StatusSummaryRow(
                counts: counts,
                onTap: handleStatusCardTap,
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
                      .collection('laporan')
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

                    return LaporanCard(
                      id: laporan.id,
                      judul: data['judul'] ?? '',
                      tanggal: formatTanggal(data['tanggal']),
                      status: '${data['status']}',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => LaporanDetailPage(
                                  id: laporan.id,
                                  judul: data['judul'] ?? 'Tanpa Judul',
                                  tanggal: formatTanggal(data['tanggal']),
                                  status: '${data['status']}',
                                  lokasi: data['lokasi'] as String?,
                                  instansi: data['instansi'] as String?,
                                  isiLaporan: data['isi'] as String?,
                                  buktiTerlampir:
                                      (data['bukti_terlampir'] ?? false)
                                          as bool,
                                ),
                          ),
                        );
                      },
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
