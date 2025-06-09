import 'package:flutter/material.dart';
import 'status_card.dart';

class StatusSummaryRow extends StatelessWidget {
  final Map<String, int> counts;
  final void Function(String status) onTap;

  const StatusSummaryRow({
    super.key,
    required this.counts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildStatusCard(
          '${counts['menunggu']}',
          'Masuk',
          Colors.blue,
          () => onTap('menunggu'),
        ),
        const SizedBox(width: 8),
        buildStatusCard(
          '${counts['terverifikasi']}',
          'Terverifikasi',
          Colors.green,
          () => onTap('terverifikasi'),
        ),
        const SizedBox(width: 8),
        buildStatusCard(
          '${counts['ditolak']}',
          'Laporan Ditolak',
          Colors.red,
          () => onTap('ditolak'),
        ),
      ],
    );
  }
}