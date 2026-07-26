import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/core/theme/theme.dart';
import 'package:hitched/features/planner/presentation/screens/planner_app.dart';

void main() {
  runApp(const HitchedApp());
}

class HitchedApp extends StatelessWidget {
  const HitchedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Hitched',
        theme: AppTheme.lightTheme,
        home: const PlannerShell(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
