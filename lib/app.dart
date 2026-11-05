import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/join/join_screen.dart';

class RumourApp extends StatelessWidget {
  const RumourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rumour',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const JoinScreen(),
    );
  }
}
