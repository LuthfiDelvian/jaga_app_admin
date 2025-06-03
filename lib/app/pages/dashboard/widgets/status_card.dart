import 'package:flutter/material.dart';

Widget buildStatusCard(String jumlah, String label, Color color) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            jumlah,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    ),
  );
}

Widget buildStatusChip(String status) {
  Color color;
  switch (status) {
    case 'selesai':
      color = Colors.green;
      break;
    case 'ditolak':
      color = Colors.red;
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
