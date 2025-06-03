import 'package:flutter/material.dart';

void showFilterDrawer(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Filter',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filter Laporan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text("Jenis Laporan"),
                  DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                      DropdownMenuItem(
                        value: 'Pengaduan',
                        child: Text('Pengaduan'),
                      ),
                      DropdownMenuItem(
                        value: 'Aspirasi',
                        child: Text('Aspirasi'),
                      ),
                    ],
                    onChanged: (_) {},
                    value: 'Semua',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Tanggal"),
                  DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                      DropdownMenuItem(
                        value: 'Terbaru',
                        child: Text('Terbaru'),
                      ),
                      DropdownMenuItem(
                        value: 'Terlama',
                        child: Text('Terlama'),
                      ),
                    ],
                    onChanged: (_) {},
                    value: 'Semua',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Urutkan"),
                  RadioListTile(
                    title: const Text("Status"),
                    value: 'status',
                    groupValue: 'status',
                    onChanged: (_) {},
                  ),
                  RadioListTile(
                    title: const Text("Tanggal"),
                    value: 'tanggal',
                    groupValue: 'status',
                    onChanged: (_) {},
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Hapus"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Terapkan filter di sini
                        },
                        child: const Text("Terapkan"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      );
    },
  );
}
