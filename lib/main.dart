import 'package:flutter/material.dart';
import 'package:juskar/utils/app_theme.dart';
import 'package:juskar/screens/main_layout.dart';

void main() {
  runApp(const JuskarApp());
}

class JuskarApp extends StatelessWidget {
  const JuskarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juskar - Repostería',
      theme: AppTheme.darkTheme,
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
