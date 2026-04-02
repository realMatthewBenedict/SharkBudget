import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class Transaction {
  Transaction(this.date, this.type, this.category, this.source, this.note, this.amount);
  const Transaction._empty() : date = "", type = "", category = "", source = "", note = "", amount = "";
  static const Transaction empty = Transaction._empty();

  final String date;
  final String type;
  final String category;
  final String source;
  final String note;
  final String amount;
}

class TransactionCell extends StatelessWidget {
  TransactionCell({
    super.key,
    this.index = 0,
    this.transaction = Transaction.empty,
    this.editable = true,
  });

  final int index;
  final Transaction transaction;
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
      child: HStack(
        [
          SizedBox(
            width: 110,
            height: 40,
            child: Text(transaction.date)
          ),
          SizedBox(
              width: 80,
              height: 40,
              child: Text(transaction.type)
          ),
          SizedBox(
              width: 80,
              height: 40,
              child: Text(transaction.category)
          ),
          SizedBox(
              width: 120,
              height: 40,
              child: Text(transaction.source)
          ),
          SizedBox(
              width: 120,
              height: 40,
              child: Text(transaction.note)
          ),
          SizedBox(
              width: 80,
              height: 40,
              child: Text(transaction.amount)
          )
        ]
      )
    );
  }
}
