import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final bool buktiTerlampir; // true jika ada bukti

  const LaporanDetailPage({
    super.key,
    required this.id,
    required this.judul,
    required this.tanggal,
    required this.status,
    this.lokasi,
    this.instansi,
    this.isiLaporan,
    this.buktiTerlampir = false,
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

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.status;
  }

  Future<void> _simpanStatus() async {
    try {
      await FirebaseFirestore.instance
          .collection('laporan')
          .doc(widget.id)
          .update({
            'status': _selectedStatus,
            'catatan_verifikasi': _catatanController.text,
          });

      // Jika berhasil
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StatusSavedPage()),
        );
      }
    } catch (e) {
      // Jika gagal
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
              '${widget.id}',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${widget.judul}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _detailRow('Tanggal', widget.tanggal),
            _detailRow('Lokasi', widget.lokasi),
            _detailRow('Instansi\nTujuan', widget.instansi),
            _detailRow('Isi\nLaporan', widget.isiLaporan),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.verified, color: Colors.green, size: 20),
                const SizedBox(width: 6),
                const Text(
                  'Bukti Terlampir',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),

            const SizedBox(height: 16),
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
                  _statusList
                      .map(
                        (item) => DropdownMenuItem(
                          value: item['value'],
                          child: Text(item['label']!),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedStatus = val);
              },
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
                hintText: 'Catatan Verifikasi (opsional)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
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
