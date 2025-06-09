import 'package:cloud_firestore/cloud_firestore.dart';

String formatTanggal(dynamic tanggal) {
  if (tanggal is Timestamp) {
    return tanggal.toDate().toString().split(' ')[0];
  }
  if (tanggal is String) {
    return tanggal;
  }
  return '-';
}