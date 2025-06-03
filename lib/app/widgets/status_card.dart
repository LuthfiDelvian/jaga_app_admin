import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String jumlah;
  final String label;
  final Color color;

  const StatusCard({
    super.key,
    required this.jumlah,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}
