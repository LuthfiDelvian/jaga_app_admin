import 'package:flutter/material.dart';

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