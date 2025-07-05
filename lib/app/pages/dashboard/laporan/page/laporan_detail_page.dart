import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:jaga_app_admin/app/pages/dashboard/laporan/helper/download_helper_web.dart';
import 'package:jaga_app_admin/app/pages/dashboard/laporan/page/status_failed_page.dart';
import 'package:jaga_app_admin/app/pages/dashboard/laporan/page/status_saved_page.dart';

class LaporanDetailPage extends StatefulWidget {
  final String id;
  final String judul;
  final String tanggal;
  final String status;
  final String? lokasi;
  final String? instansi;
  final String? isiLaporan;

  const LaporanDetailPage({
    super.key,
    required this.id,
    required this.judul,
    required this.tanggal,
    required this.status,
    this.lokasi,
    this.instansi,
    this.isiLaporan,
  });

  @override
  State<LaporanDetailPage> createState() => _LaporanDetailPageState();
}

class _LaporanDetailPageState extends State<LaporanDetailPage> {
  late String _selectedStatus;
  final TextEditingController _catatanController = TextEditingController();

  final List<Map<String, String>> _statusList = [
    {'value': 'Menunggu', 'label': 'Menunggu'},
    {'value': 'Diproses', 'label': 'Diproses'},
    {'value': 'Selesai', 'label': 'Selesai'},
    {'value': 'Ditolak', 'label': 'Ditolak'},
  ];

  List<Map<String, dynamic>> _buktiList = [];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.status;
    _fetchBukti();
  }

  Future<void> _fetchBukti() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('laporan')
            .doc(widget.id)
            .get();
    final data = doc.data();
    if (data != null && data['bukti'] != null) {
      setState(() {
        _buktiList = List<Map<String, dynamic>>.from(data['bukti']);
      });
    }
  }

  Future<void> _downloadFile(String url) async {
    // downloadFile(url);
  }

  Widget _detailRow(String label, String? value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuktiList() {
    if (_buktiList.isEmpty) return const Text('Tidak ada bukti terlampir.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          _buktiList.map((file) {
            final String url = file['url'];
            final String name = file['name'];
            final String type = (file['type'] ?? '').toLowerCase();
            final bool isImage = ['jpg', 'jpeg', 'png', 'webp'].contains(type);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child:
                  isImage
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      )
                      : ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(name, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => _downloadFile(url),
                        ),
                      ),
            );
          }).toList(),
    );
  }

  Future<void> _simpanStatus() async {
    try {
      final laporanRef = FirebaseFirestore.instance
          .collection('laporan')
          .doc(widget.id);
      final laporanDoc = await laporanRef.get();
      final laporanData = laporanDoc.data();
      final userId = laporanData?['uid'];

      await laporanRef.update({
        'status': _selectedStatus,
        'catatan_verifikasi': _catatanController.text,
      });

      // Kirim notifikasi ke user pelapor
      if (userId != null) {
        await FirebaseFirestore.instance.collection('notifikasi').add({
          'userId': userId,
          'text':
              'Status laporan "${widget.judul}" telah diubah menjadi $_selectedStatus',
          'createdAt': FieldValue.serverTimestamp(),
          'laporanId': widget.id,
          'type': 'laporan',
        });
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StatusSavedPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StatusFailedPage(errorMessage: e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/jaga-icon.png',
          color: Colors.white,
          height: 85,
        ),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              widget.id,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                widget.judul,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _detailRow('Tanggal', widget.tanggal),
            _detailRow('Lokasi', widget.lokasi),
            _detailRow('Instansi\nTujuan', widget.instansi),
            _detailRow('Isi\nLaporan', widget.isiLaporan),
            const SizedBox(height: 16),
            const Text(
              'Bukti Terlampir',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildBuktiList(),
            const SizedBox(height: 24),
            const Text(
              'Pilih Status Laporan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(),
              ),
              items:
                  _statusList.map((item) {
                    return DropdownMenuItem(
                      value: item['value'],
                      child: Text(item['label']!),
                    );
                  }).toList(),
              onChanged:
                  (val) =>
                      setState(() => _selectedStatus = val ?? _selectedStatus),
            ),
            const SizedBox(height: 16),
            const Text(
              'Catatan Verifikasi [opsional]',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _catatanController,
              decoration: const InputDecoration(
                hintText: 'Catatan Verifikasi',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _simpanStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Simpan Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
