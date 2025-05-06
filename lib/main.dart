import 'package:flutter/material.dart';

import 'package:test_work_sapce/hiveDatabase.dart';
import 'package:test_work_sapce/homeScreen.dart';
import 'package:test_work_sapce/noteField.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hiveService = HiveService();
  await hiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaza NotePad',
      home:Scaffold(
        body: Notefield()
        ),
    );
  }
}