import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaga_app_admin/app/pages/dashboard/laporan/page/laporan_detail_page.dart';
import 'package:jaga_app_admin/app/pages/dashboard/laporan/widgets/laporan_card.dart';
import 'package:jaga_app_admin/app/pages/dashboard/laporan/widgets/status_color.dart';
import 'package:jaga_app_admin/app/pages/dashboard/laporan/widgets/title_card.dart';
import 'package:jaga_app_admin/app/pages/dashboard/utils/format_tanggal.dart';

class FilteredLaporanPage extends StatelessWidget {
  final List<String> statusList;
  final String title;

  const FilteredLaporanPage({
    super.key,
    required this.statusList,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Image.asset(
          'assets/images/jaga-icon.png',
          color: Colors.white,
          height: 85,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          buildTitleCard(title, getStatusColor(title)),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('laporan')
                      .where('status', whereIn: statusList)
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
                    final status = data['status'] ?? '-';

                    return LaporanCard(
                      judul: data['judul'] ?? 'Tanpa Judul',
                      id: laporan.id,
                      status: status,
                      tanggal: formatTanggal(data['tanggal']),
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
