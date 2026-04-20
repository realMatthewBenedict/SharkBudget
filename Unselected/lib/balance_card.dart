import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:c2/app_colors.dart';

class Balance {
  const Balance({
    this.incomeCents = 0,
    this.incomePercentDiff = 0,
    this.expensesCents = 0,
    this.expensePercentDiff = 0,
    this.netCents = 0,
    this.netPercentDiff = 0,
  });

  final int incomeCents;
  final double incomePercentDiff;
  final int expensesCents;
  final double expensePercentDiff;
  final int netCents;
  final double netPercentDiff;
}

final ValueNotifier<Balance> balanceNotifier = ValueNotifier(Balance());

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Balance>(
      valueListenable: balanceNotifier,
      builder: (context, balance, child) {
        return Container(
          height: 200,
          color: AppColors.contentColorBlue,
          child: HStack(spacing: 20, [
            VStack(
              [
                Text('Total Income'),
                Text(
                  '\$${(balance.incomeCents / 100).toStringAsFixed(2)}',
                  style: DefaultTextStyle.of(context).style.apply(
                    color: Colors.black54,
                    decorationStyle: .dashed,
                    fontSizeFactor: 1.5,
                  ),
                ),
                Text(
                  '${balance.incomePercentDiff.toStringAsFixed(1)}% vs last period',
                  style: DefaultTextStyle.of(context).style.apply(
                    color: AppColors.contentColorGreen,
                    decoration: .none,
                    fontSizeFactor: 1.0,
                  ),
                ),
              ],
              crossAlignment: CrossAxisAlignment.start,
              axisSize: MainAxisSize.min,
            ),
            VStack(
              [
                Text('Total Expenses'),
                Text(
                  '\$${(balance.expensesCents / 100).toStringAsFixed(2)}',
                  style: DefaultTextStyle.of(context).style.apply(
                    color: Colors.black54,
                    decorationStyle: .dashed,
                    fontSizeFactor: 1.5,
                  ),
                ),
                Text(
                  '${balance.expensePercentDiff.toStringAsFixed(1)}% vs last period',
                  style: DefaultTextStyle.of(context).style.apply(
                    color: AppColors.contentColorGreen,
                    decoration: .none,
                    fontSizeFactor: 1.0,
                  ),
                ),
              ],
              crossAlignment: CrossAxisAlignment.start,
              axisSize: MainAxisSize.min,
            ),
            VStack(
              [
                Text('Net Balance'),
                Text(
                  '\$${(balance.netCents / 100).toStringAsFixed(2)}',
                  style: DefaultTextStyle.of(context).style.apply(
                    color: Colors.black54,
                    decorationStyle: .dashed,
                    fontSizeFactor: 1.5,
                  ),
                ),
                Text(
                  '${balance.netPercentDiff.toStringAsFixed(1)}% vs last period',
                  style: DefaultTextStyle.of(context).style.apply(
                    color: AppColors.contentColorGreen,
                    decoration: .none,
                    fontSizeFactor: 1.0,
                  ),
                ),
              ],
              crossAlignment: CrossAxisAlignment.start,
              axisSize: MainAxisSize.min,
            ),
          ]),
        );
      },
    );
  }
}
