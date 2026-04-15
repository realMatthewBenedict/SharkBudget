import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

final ValueNotifier<List<TransactionString>> transactionsNotifier =
    ValueNotifier<List<TransactionString>>([
      TransactionString.header(),
      Transaction(
        null,
        1772409600,
        "Expense",
        "Housing",
        "Rent Payment",
        "Monthly rent",
        120000,
      ).toTransString(),
      Transaction(
        null,
        1772496000,
        "Expense",
        "Food",
        "Walmart",
        "–",
        8550,
      ).toTransString(),
      Transaction(
        null,
        1772496000,
        "Expense",
        "Transport",
        "Gas Station",
        "–",
        4500,
      ).toTransString(),
    ]);

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
    this.unixDate,
    this.type,
    this.category,
    this.source,
    this.note,
    this.amount,
  );

  int? id;
  final int unixDate;
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

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('transaction_$index'),
      background: Container(
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.edit, color: Colors.white),
            Text('Edit', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Icon(Icons.delete, color: Colors.white),
            Text('Delete', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      onDismissed: (direction) {
        // Handle swipe actions
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
