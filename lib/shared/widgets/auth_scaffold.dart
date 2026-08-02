import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'entrance_animation.dart';
import 'hitched_illustration.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.blush, AppColors.ivory, AppColors.sageSoft],
            stops: [0, 0.58, 1],
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
                        children: [
                          const EntranceAnimation(child: _BrandMark()),
                          for (var index = 0; index < children.length; index++)
                            EntranceAnimation(
                              delay: Duration(milliseconds: 70 + index * 45),
                              child: children[index],
                            ),
                        ],
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
        HitchedIllustration.mark(),
        SizedBox(height: 4),
        Text(
          'hitched',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.deepPlum,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 28),
      ],
    );
  }
}
