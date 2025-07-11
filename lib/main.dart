import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jaga_app_admin/app/app.dart';
import 'app/services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
