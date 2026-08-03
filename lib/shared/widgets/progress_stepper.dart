import 'package:flutter/material.dart';

class ProgressStepper extends StatelessWidget {
  const ProgressStepper({
    required this.currentStep,
    required this.labels,
    super.key,
  });

  final int currentStep;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label:
          'Step ${currentStep + 1} of ${labels.length}: ${labels[currentStep]}',
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++) ...[
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: index == currentStep ? 38 : 32,
                  height: index == currentStep ? 38 : 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index <= currentStep
                        ? scheme.primary
                        : scheme.surface,
                    border: Border.all(
                      color: index <= currentStep
                          ? scheme.primary
                          : scheme.outline,
                    ),
                  ),
                  child: index < currentStep
                      ? Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: scheme.onPrimary,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index <= currentStep
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
                const SizedBox(height: 5),
                Text(
                  labels[index],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: index <= currentStep
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                    fontWeight: index == currentStep
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (index < labels.length - 1)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 2,
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 20),
                  color: index < currentStep ? scheme.primary : scheme.outline,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
