import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:c2/app_colors.dart';
import 'package:c2/main.dart';

class TransactionString {
  TransactionString.header();
  TransactionString(
    this.id,
    this.date,
    this.type,
    this.category,
    this.source,
    this.note,
    this.amount,
  );

  String id = "ID";
  String date = "Date";
  String type = "Type";
  String category = "Category";
  String source = "Source/Merchant";
  String note = "Note";
  String amount = "Amount";
}

class Transaction {
  Transaction(
    this.id,
    this.username,
    this.unixDate,
    this.type,
    this.category,
    this.source,
    this.note,
    this.amount,
  );

  int? id;
  final int unixDate;
  final String username;
  final String type;
  final String category;
  final String source;
  final String note;
  final int amount;

  TransactionString toTransString() {
    return TransactionString(
      '$id',
      DateTime.fromMillisecondsSinceEpoch(unixDate * 1000).toIso8601String(),
      type,
      category,
      source,
      note,
      '\$${(amount / 100).toStringAsFixed(2)}',
    );
  }
}

class TransactionCell extends StatelessWidget {
  const TransactionCell({
    super.key,
    required this.transaction,
    this.index = 0,
    this.editable = true,
  });

  final int index;
  final TransactionString transaction;
  final bool editable;

  void showEditDialog(BuildContext context) {
    final notesController = TextEditingController(text: transaction.note);
    final amountController = TextEditingController(
      text: transaction.amount.replaceAll('\$', ''),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount (e.g., 45.00)',
                prefixText: '\$',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final dollars = double.parse(amountController.text);
              final cents = (dollars * 100).toStringAsFixed(0);

              gRequestManager.sendRequest(
                'kTransactionEditRequest',
                '${transaction.id},$gCurrentUsername,${notesController.text},$cents',
              );

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('transaction_$index'),
      background: Container(
        color: AppColors.contentColorBlue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.edit, color: Colors.white),
            const Text('Edit', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: AppColors.contentColorRed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            const Icon(Icons.delete, color: Colors.white),
            const Text('Delete', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (!editable) return false;

        // Left swipe (will finish): treat as edit, not delete
        if (direction == DismissDirection.startToEnd) {
          showEditDialog(context);
          return false; // DON'T remove from list
        }

        // Right swipe (will finish): delete
        if (direction == DismissDirection.endToStart) {
          gRequestManager.sendRequest(
            'kTransactionDeleteRequest',
            '${transaction.id},$gCurrentUsername',
          );
          return true; // remove from list
        }

        return false;
      },
      child: HStack([
        SizedBox(width: 200, height: 40, child: Text(transaction.date)),
        SizedBox(width: 80, height: 40, child: Text(transaction.type)),
        SizedBox(width: 80, height: 40, child: Text(transaction.category)),
        SizedBox(width: 120, height: 40, child: Text(transaction.source)),
        SizedBox(width: 120, height: 40, child: Text(transaction.note)),
        SizedBox(width: 80, height: 40, child: Text(transaction.amount)),
      ]),
    );
  }
}

class TransactionListSection extends StatelessWidget {
  static final ValueNotifier<List<TransactionString>> transactionsNotifier =
      ValueNotifier<List<TransactionString>>([
        TransactionString.header(),
        Transaction(
          null,
          "admin",
          1772409600,
          "Expense",
          "Housing",
          "Rent Payment",
          "Monthly rent",
          120000,
        ).toTransString(),
        Transaction(
          null,
          "admin",
          1772496000,
          "Expense",
          "Food",
          "Walmart",
          "–",
          8550,
        ).toTransString(),
        Transaction(
          null,
          "admin",
          1772496000,
          "Expense",
          "Transport",
          "Gas Station",
          "–",
          4500,
        ).toTransString(),
      ]);
  final VoidCallback addTransaction;

  const TransactionListSection({super.key, required this.addTransaction});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TransactionString>>(
      valueListenable: transactionsNotifier,
      builder: (context, transactions, child) {
        return VStack([
          FloatingActionButton(
            onPressed: addTransaction,
            tooltip: 'Add Transaction',
            child: const Icon(Icons.add),
          ),
          ...transactions.asMap().entries.map((entry) {
            final index = entry.key;
            final transaction = entry.value;
            return TransactionCell(
              index: index,
              transaction: transaction,
              editable: index != 0,
            );
          }),
        ]);
      },
    );
  }
}
