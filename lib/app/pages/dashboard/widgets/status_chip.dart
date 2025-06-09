import 'package:flutter/material.dart';

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