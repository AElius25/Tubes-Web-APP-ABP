import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionProvider>();
    final revenues = tx.weeklyRevenue;
    final maxRevenue = revenues.isEmpty
        ? 1.0
        : revenues.reduce((a, b) => a > b ? a : b);
    final fmt = NumberFormat.compactCurrency(
        locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final now = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return days[d.weekday - 1];
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total: ${fmt.format(revenues.fold(0.0, (a, b) => a + b))}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final rev = revenues[i];
                final height = maxRevenue > 0
                    ? (rev / maxRevenue * 100).clamp(4.0, 100.0)
                    : 4.0;
                final isToday = i == 6;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (rev > 0)
                          Text(fmt.format(rev),
                            style: const TextStyle(fontSize: 8,
                              color: Colors.grey),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: height,
                          decoration: BoxDecoration(
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(dayLabels[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          )),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ]),
      ),
    );
  }
}
