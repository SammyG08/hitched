import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF1F3), Color(0xFFFFF9F6)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 60,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [const _BrandMark(), ...children],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Color(0xFF9D4E62),
          child: Icon(Icons.favorite_rounded, color: Colors.white, size: 30),
        ),
        SizedBox(height: 12),
        Text(
          'hitched',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF302A2C),
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 36),
      ],
    );
  }
}
