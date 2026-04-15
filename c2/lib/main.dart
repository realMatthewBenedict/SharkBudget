import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:c2/app_colors.dart';
import 'package:c2/cash_flow_line_chart.dart';
import 'package:c2/c2_request.dart';
import 'package:c2/expenses_pie_chart.dart';
import 'package:c2/transaction_cell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(
          seedColor: Colors.deepPurple,
          brightness: .light,
        ),
        /* light theme settings */
      ),
      darkTheme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple, brightness: .dark),
        /* dark theme settings */
      ),
      themeMode: ThemeMode.system,
      home: const MainContent(),
    );
  }
}

class MainContent extends StatefulWidget {
  const MainContent({super.key});

  @override
  State<MainContent> createState() => MainContentState();
}

class MainContentState extends State<MainContent>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sendRequest("kCashFlowRequest", "");
      sendRequest("kExpenseReportRequest", "");
      sendRequest("kTransactionListRequest", "");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addTransaction() {
    // Controllers for each field (dispose them if reusing)
    final dateController = TextEditingController();
    final typeController = TextEditingController();
    final categoryController = TextEditingController();
    final sourceController = TextEditingController();
    final noteController = TextEditingController();
    final amountController = TextEditingController();

    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text('Add Transaction'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Date picker field
                  InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate ?? now,
                        firstDate: DateTime(now.year - 5),
                        lastDate: DateTime(now.year + 1),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                          dateController.text = DateFormat(
                            'd MMMM yyyy',
                          ).format(picked);
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        dateController.text.isEmpty
                            ? 'Pick a date'
                            : dateController.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Type
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(
                      labelText: 'Type (e.g., Expense)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category (e.g., Food)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Source/Merchant
                  TextField(
                    controller: sourceController,
                    decoration: const InputDecoration(
                      labelText: 'Source/Merchant',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Note
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Amount
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount (e.g., 45.00)',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final unixSeconds = selectedDate == null
                      ? ''
                      : (selectedDate!.millisecondsSinceEpoch ~/ 1000)
                            .toString();
                  final dollars = double.parse(amountController.text);
                  final cents = (dollars * 100).toStringAsFixed(0);
                  sendRequest(
                    "kNewTransactionRequest",
                    "$unixSeconds,${typeController.text},"
                        "${categoryController.text},${sourceController.text},"
                        "${noteController.text},$cents",
                  );
                  // Close dialog
                  Navigator.pop(context);
                  // Clean up
                  dateController.dispose();
                  typeController.dispose();
                  categoryController.dispose();
                  sourceController.dispose();
                  noteController.dispose();
                  amountController.dispose();
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: HStack(spacing: 10.0, [
          Text(
            'Shark Budget',
            style: DefaultTextStyle.of(context).style.apply(
              color: AppColors.contentColorBlue,
              decoration: .none,
              fontSizeFactor: 0.5,
            ),
          ),
          FittedBox(
            fit: BoxFit.contain, // otherwise the logo will be tiny
            child: Image.asset(
              'images/shark_budget.jpg',
              width: 50,
              height: 50,
            ),
          ),
        ]),
        bottom: TabBar(
          controller: _controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Details'),
            Tab(text: 'Charts'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          // Dashboard
          ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              FloatingActionButton(
                onPressed: addTransaction,
                tooltip: 'Add Transaction',
                child: const Icon(Icons.add),
              ),
              Container(
                height: 200,
                color: AppColors.contentColorPurple,
                child: ExpensesPieChart(),
              ),
              Container(
                height: 200,
                color: AppColors.contentColorYellow,
                child: CashFlowLineChart(),
              ),
              Container(
                height: 200,
                color: AppColors.contentColorBlue,
                child: HStack(spacing: 20, [
                  VStack(
                    [
                      Text('Total Income'),
                      Text(
                        '\$0.00',
                        style: DefaultTextStyle.of(context).style.apply(
                          color: Colors.black54,
                          decorationStyle: .dashed,
                          fontSizeFactor: 0.5,
                        ),
                      ),
                      Text(
                        '+8% vs last period',
                        style: DefaultTextStyle.of(context).style.apply(
                          color: AppColors.contentColorGreen,
                          decoration: .none,
                          fontSizeFactor: 0.3,
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
                        '\$1515.80',
                        style: DefaultTextStyle.of(context).style.apply(
                          color: Colors.black54,
                          decorationStyle: .dashed,
                          fontSizeFactor: 0.5,
                        ),
                      ),
                      Text(
                        '+3% vs last period',
                        style: DefaultTextStyle.of(context).style.apply(
                          color: AppColors.contentColorGreen,
                          decoration: .none,
                          fontSizeFactor: 0.3,
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
                        '-\$1515.80',
                        style: DefaultTextStyle.of(context).style.apply(
                          color: Colors.black54,
                          decorationStyle: .dashed,
                          fontSizeFactor: 0.5,
                        ),
                      ),
                      Text(
                        'Income – Expense',
                        style: DefaultTextStyle.of(context).style.apply(
                          color: Colors.black26,
                          decoration: .none,
                          fontSizeFactor: 0.3,
                        ),
                      ),
                    ],
                    crossAlignment: CrossAxisAlignment.start,
                    axisSize: MainAxisSize.min,
                  ),
                ]),
              ),
            ],
          ),

          // Details
          ValueListenableBuilder<List<TransactionString>>(
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
                    editable: index == 0 ? false : true, // Header non-editable
                  );
                }),
              ]);
            },
          ),

          // Charts
          CashFlowLineChart(),

          // Settings
          Center(
            child: VStack(spacing: 20.0, [
              Icon(Icons.settings, color: Colors.deepPurple, size: 30.0),
              Text('Settings and configuration options.'),
            ]),
          ),
        ],
      ),
    );
  }
}
