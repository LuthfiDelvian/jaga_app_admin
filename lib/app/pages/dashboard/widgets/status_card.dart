import 'package:flutter/material.dart';

Widget buildStatusCard(
  String jumlah,
  String label,
  Color color,
  VoidCallback onTap,
) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              jumlah,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    ),
  );
}