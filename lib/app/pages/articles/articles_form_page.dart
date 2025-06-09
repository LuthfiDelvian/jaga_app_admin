import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class ArticleFormPage extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? existingData;

  const ArticleFormPage({super.key, this.isEdit = false, this.existingData});

  @override
  State<ArticleFormPage> createState() => _ArticleFormPageState();
}

class _ArticleFormPageState extends State<ArticleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _kontenController = TextEditingController();

  File? _pickedImage; // for mobile
  Uint8List? _pickedImageBytes; // for web
  String? _pickedImageName;

  String? _uploadedImageUrl; // url gambar Cloudinary
  String? _imageFileName; // public_id di Cloudinary, juga id dokumen Firestore

  String? _selectedKategori;
  String? _selectedStatus = 'draft';

  final List<String> kategoriList = ['Pilih', 'Kasus Korupsi', 'Edukasi', 'Berita'];
  final List<Map<String, String>> statusList = [
    {'value': 'draft', 'label': 'Draft'},
    {'value': 'terbit', 'label': 'Terbitkan'},
    {'value': 'jadwalkan', 'label': 'Dijadwalkan'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingData != null) {
      final d = widget.existingData!;
      _judulController.text = d['judul'] ?? '';
      _kontenController.text = d['konten'] ?? '';
      _uploadedImageUrl = d['image_url'];
      _imageFileName = d['id']; // id dokumen Firestore
      _selectedKategori = d['kategori'];
      _selectedStatus = d['status'];
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result != null) {
      if (kIsWeb) {
        setState(() {
          _pickedImageBytes = result.files.single.bytes;
          _pickedImageName = result.files.single.name;
          _pickedImage = null;
        });
      } else {
        setState(() {
          _pickedImage = File(result.files.single.path!);
          _pickedImageBytes = null;
          _pickedImageName = null;
        });
      }
    }
  }

  Future<bool> _uploadImageToCloudinary() async {
    if (_pickedImage == null && _pickedImageBytes == null) return false;

    final cloudName = 'dp0iysyni'; // GANTI sesuai Cloudinary kamu
    final uploadPreset = 'jaga_articles'; // GANTI sesuai Cloudinary kamu
    final fileName = _imageFileName ?? DateTime.now().millisecondsSinceEpoch.toString();

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['public_id'] = fileName;

    if (kIsWeb && _pickedImageBytes != null && _pickedImageName != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _pickedImageBytes!,
          filename: _pickedImageName!,
        ),
      );
    } else if (_pickedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('file', _pickedImage!.path),
      );
    } else {
      return false;
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final jsonResp = json.decode(respStr);
      setState(() {
        _uploadedImageUrl = jsonResp['secure_url'];
        _imageFileName = jsonResp['public_id'];
      });
      return true;
    } else {
      return false;
    }
  }

  Future<void> _simpanArtikel({required bool isDraft}) async {
    if (!_formKey.currentState!.validate()) return;

    // Jika ada gambar baru, upload, jika tidak pakai url lama
    if ((_pickedImage != null || _pickedImageBytes != null)) {
      final result = await _uploadImageToCloudinary();
      if (!result) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal upload gambar ke Cloudinary')));
        return;
      }
    }

    if (_uploadedImageUrl == null || _imageFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload gambar terlebih dahulu!')));
      return;
    }

    final artikelData = {
      'id': _imageFileName,
      'judul': _judulController.text.trim(),
      'konten': _kontenController.text.trim(),
      'image_url': _uploadedImageUrl,
      'kategori': _selectedKategori ?? '',
      'status': isDraft ? 'draft' : _selectedStatus,
      'tanggal': DateTime.now(),
    };

    await FirebaseFirestore.instance
        .collection('artikel')
        .doc(_imageFileName)
        .set(artikelData, SetOptions(merge: true));

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JAGA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.red,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Judul Artikel', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan judul artikel',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45),
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.grey[100],
                  ),
                  child: _uploadedImageUrl != null || _pickedImage != null || _pickedImageBytes != null
                      ? (kIsWeb
                          ? (_pickedImageBytes != null
                              ? Image.memory(_pickedImageBytes!, height: 120, fit: BoxFit.cover)
                              : Image.network(_uploadedImageUrl!, height: 120, fit: BoxFit.cover))
                          : (_pickedImage != null
                              ? Image.file(_pickedImage!, height: 120, fit: BoxFit.cover)
                              : Image.network(_uploadedImageUrl!, height: 120, fit: BoxFit.cover)))
                      : const Center(
                          child: Text('+ Unggah Gambar', style: TextStyle(color: Colors.black54)),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Konten Artikel', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _kontenController,
                minLines: 5,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Masukkan artikel',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Konten wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _selectedKategori,
                          items: kategoriList
                              .map((k) => DropdownMenuItem(
                                    value: k,
                                    child: Text(k),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedKategori = val),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Column(
                          children: statusList.map((s) {
                            return RadioListTile<String>(
                              value: s['value']!,
                              groupValue: _selectedStatus,
                              title: Text(s['label']!),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (v) => setState(() => _selectedStatus = v),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _simpanArtikel(isDraft: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: const Text('Simpan Draft', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _simpanArtikel(isDraft: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: const Text('Terbitkan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}