import 'package:flutter/material.dart';
import 'package:jaga_app_admin/app/pages/dashboard/widgets/status_chip.dart';

class LaporanCard extends StatelessWidget {
  final String id;
  final String judul;
  final String tanggal;
  final String status;
  final VoidCallback? onTap;

  const LaporanCard({
    super.key,
    required this.id,
    required this.judul,
    required this.tanggal,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(id),
        subtitle: Text(judul),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(tanggal),
            const SizedBox(height: 4),
            buildStatusChip(status),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
