import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/core/theme/theme.dart';
import 'package:hitched/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: HitchedApp(),
    ),
  );
}

class HitchedApp extends StatelessWidget {
  const HitchedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hitched',
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
