import 'package:flutter/material.dart';
import 'package:jaga_app/app/pages/articles/page/articles_page.dart';
import 'package:jaga_app/app/pages/report/form_page.dart';
import 'package:jaga_app/app/pages/home/page/home_page.dart';
import 'package:jaga_app/app/pages/more/pages/more_page.dart';

/// Daftar halaman utama untuk navigasi bawah (bottom nav)
final List<Widget> appPages = [
  const HomePage(),
  const ArticlesPage(),
  const FormPage(),
  const MorePage(),
];