import 'package:flutter/material.dart';
import 'screens/settings/general_page.dart';

void main() {
  runApp(const ArgusApp());
}

class ArgusApp extends StatelessWidget {
  const ArgusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Argus',
      home: const GeneralPage(),
    );
  }
}