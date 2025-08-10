import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LaporanDonutChart extends StatelessWidget {
  final int masuk;
  final int terverifikasi;
  final int ditolak;
  final DateTime? firstDate;

  const LaporanDonutChart({
    super.key,
    required this.masuk,
    required this.terverifikasi,
    required this.ditolak,
    this.firstDate,
  });

  @override
  Widget build(BuildContext context) {
    final total = masuk + terverifikasi + ditolak;
    double percent(int value) => total == 0 ? 0 : (value / total * 100);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.red.shade200, width: 1.5),
      ),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Laporan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (firstDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 10),
                child: Text(
                  'Laporan sejak ${_formatDate(firstDate!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            const SizedBox(height: 18),
            Center(
              child: SizedBox(
                width: 130,
                height: 130,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 40,
                    sectionsSpace: 4,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        value: masuk.toDouble(),
                        color: Colors.blueAccent,
                        title: '',
                        radius: 42,
                      ),
                      PieChartSectionData(
                        value: terverifikasi.toDouble(),
                        color: Colors.green,
                        title: '',
                        radius: 42,
                      ),
                      PieChartSectionData(
                        value: ditolak.toDouble(),
                        color: Colors.red,
                        title: '',
                        radius: 42,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Ganti Row legend jadi:
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8, // Jarak horizontal
              runSpacing: 6, // Jarak antar baris kalau turun ke bawah
              children: [
                _LegendItem(
                  color: Colors.blueAccent,
                  text: 'Masuk',
                  percent: percent(masuk),
                ),
                _LegendItem(
                  color: Colors.green,
                  text: 'Terverifikasi',
                  percent: percent(terverifikasi),
                ),
                _LegendItem(
                  color: Colors.red,
                  text: 'Ditolak',
                  percent: percent(ditolak),
                ),
              ],
            ),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.day} ${_bulanIndo(d.month)} ${d.year}';
  }

  static String _bulanIndo(int m) {
    const bln = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return bln[m];
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  final double percent;
  const _LegendItem({
    required this.color,
    required this.text,
    required this.percent,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            '(${percent.toStringAsFixed(1)}%)',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
