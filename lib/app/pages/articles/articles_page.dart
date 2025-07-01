import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jaga_app_admin/app/pages/articles/articles_form_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ArticlesPage extends StatelessWidget {
  const ArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Artikel',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ArticleFormPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Tambah Artikel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('artikel')
                .orderBy('tanggal', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada artikel.'));
          }

          final artikelList = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: artikelList.length,
            itemBuilder: (context, index) {
              final doc = artikelList[index];
              final data = doc.data() as Map<String, dynamic>;
              final judul = data['judul'] ?? '';
              final konten = data['konten'] ?? '';
              final imageUrl = data['image_url'] ?? '';
              final tanggal =
                  data['tanggal'] is Timestamp
                      ? (data['tanggal'] as Timestamp)
                          .toDate()
                          .toString()
                          .split(' ')[0]
                      : (data['tanggal'] ?? '');

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tampilkan gambar di atas
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),

                    // Konten artikel
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            judul,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Dibuat pada: $tanggal',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            konten.length > 140
                                ? '${konten.substring(0, 140)}...'
                                : konten,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Konfirmasi'),
                                          content: const Text(
                                            'Yakin ingin menghapus artikel ini?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: const Text(
                                                'Hapus',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (confirm == true) {
                                    final imageUrl = data['image_url'];
                                    if (imageUrl != null &&
                                        imageUrl.toString().contains(
                                          'cloudinary.com',
                                        )) {
                                      try {
                                        final uri = Uri.parse(imageUrl);
                                        final segments = uri.pathSegments;
                                        final fileName = segments.last;
                                        final folderIndex =
                                            segments.indexOf('upload') + 1;
                                        final publicIdSegments = segments
                                          .sublist(
                                            folderIndex,
                                            segments.length - 1,
                                          )..add(fileName.split('.').first);
                                        final publicId = publicIdSegments.join(
                                          '/',
                                        );

                                        const cloudName = 'dp0iysyni';
                                        const apiKey = 'CLOUDINARY_API_KEY';
                                        const apiSecret =
                                            'CLOUDINARY_API_SECRET';

                                        final timestamp =
                                            DateTime.now()
                                                .millisecondsSinceEpoch ~/
                                            1000;
                                        final signatureString =
                                            'public_id=$publicId&timestamp=$timestamp$apiSecret';
                                        final signature =
                                            sha1
                                                .convert(
                                                  utf8.encode(signatureString),
                                                )
                                                .toString();

                                        final deleteResponse = await http.post(
                                          Uri.parse(
                                            'https://api.cloudinary.com/v1_1/$cloudName/image/destroy',
                                          ),
                                          body: {
                                            'public_id': publicId,
                                            'api_key': apiKey,
                                            'timestamp': '$timestamp',
                                            'signature': signature,
                                          },
                                        );

                                        final deleteResult = json.decode(
                                          deleteResponse.body,
                                        );
                                        if (deleteResult['result'] != 'ok') {
                                          debugPrint(
                                            'Gagal hapus gambar Cloudinary: ${deleteResult['result']}',
                                          );
                                        }
                                      } catch (e) {
                                        debugPrint(
                                          'Error hapus Cloudinary: $e',
                                        );
                                      }
                                    }

                                    // Hapus dokumen
                                    await doc.reference.delete();

                                    // Tampilkan snackbar
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Artikel berhasil dihapus',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ArticleFormPage(
                                            isEdit: true,
                                            existingData: data,
                                          ),
                                    ),
                                  );

                                  if (result == 'updated' && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Artikel berhasil diperbarui',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
