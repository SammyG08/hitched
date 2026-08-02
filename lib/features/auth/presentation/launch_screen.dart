import 'package:flutter/material.dart';

class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded, color: Color(0xFF9D4E62), size: 54),
            SizedBox(height: 18),
            Text(
              'hitched',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
