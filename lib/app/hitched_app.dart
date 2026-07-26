import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/app/app_shell.dart';
import 'package:hitched/core/state/app_controller.dart';
import 'package:hitched/core/theme/theme.dart';
import 'package:hitched/features/auth/presentation/auth_screen.dart';

class HitchedApp extends ConsumerWidget {
  const HitchedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Hitched',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(
      appControllerProvider.select((state) => state.currentUser),
    );
    return user == null ? const AuthScreen() : const AppShell();
  }
}
