import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaga_app_admin/app/pages/laporan/widgets/laporan_card.dart';
import 'package:jaga_app_admin/app/pages/laporan/widgets/laporan_donut_chart.dart';
import 'laporan_detail_page.dart';
import 'filtered_laporan_page.dart';
import '../../dashboard/widgets/status_summary.dart';
import '../../dashboard/utils/format_tanggal.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
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
      child: Expanded(
        child: Column(
          children: [
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
        
                DateTime? firstDate;
                for (final doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final tgl = data['createdAt'];
                  if (tgl is Timestamp) {
                    final dt = tgl.toDate();
                    if (firstDate == null || dt.isBefore(firstDate)) {
                      firstDate = dt;
                    }
                  }
                }
        
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
        
                return Column(
                  children: [
                    StatusSummaryRow(counts: counts, onTap: handleStatusCardTap),
                    const SizedBox(height: 20),
        
                    LaporanDonutChart(
                      masuk: masuk,
                      terverifikasi: terverifikasi,
                      ditolak: ditolak,
                      firstDate: firstDate,
                    ),
                    const SizedBox(height: 12),
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
      ),
    );
  }
}
