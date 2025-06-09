import 'package:flutter/material.dart';

Widget buildTitleCard(String title, Color color) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      title,
      style: TextStyle(fontSize: 18, color: color),
      textAlign: TextAlign.center,
    ),
  );
}
