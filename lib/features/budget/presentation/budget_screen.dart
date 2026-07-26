import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hitched/core/state/app_controller.dart';
import 'package:hitched/core/theme/theme.dart';
import 'package:hitched/core/widgets/hitched_widgets.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);
    final budget = state.couple.budgetCents;
    final spent = state.bookedSpendCents;
    return HitchedScaffold(
      title: 'Private budget',
      subtitle: 'Visible only to the groom',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    money(budget),
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Text(
                    'Bride marketplace results are quietly filtered by this threshold. The budget value is not shown in bride screens.',
                  ),
                  Slider(
                    value: budget.toDouble(),
                    min: 150000000,
                    max: 1000000000,
                    divisions: 17,
                    label: money(budget),
                    onChanged: (value) => controller.setBudget(value.round()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spend analytics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: budget == 0 ? 0 : (spent / budget).clamp(0, 1),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(99),
                    color: AppColors.merlot,
                  ),
                  const SizedBox(height: 10),
                  Text('${money(spent)} confirmed against ${money(budget)}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
