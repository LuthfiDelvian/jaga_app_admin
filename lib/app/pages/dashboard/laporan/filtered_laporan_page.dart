import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilteredLaporanPage extends StatelessWidget {
  final List<String> statusList;
  final String title;

  const FilteredLaporanPage({
    super.key,
    required this.statusList,
    required this.title,
  });

  Widget buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'selesai':
        color = Colors.green;
        break;
      case 'ditolak':
        color = Colors.red;
        break;
      case 'diproses':
        color = Colors.blueGrey;
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

  Widget buildTitleCard(String title, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, color: color),
        textAlign: TextAlign.center,
      ),
    );
  }

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

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(data['judul'] ?? 'Tanpa Judul'),
                        subtitle: Text('ID: ${laporan.id}'),
                        trailing: buildStatusChip(status),
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

Color getStatusColor(String title) {
  switch (title.toLowerCase()) {
    case 'laporan masuk':
      return Colors.blue;
    case 'laporan terverifikasi':
      return Colors.green;
    case 'laporan ditolak':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
