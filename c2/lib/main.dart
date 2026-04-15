import 'package:flutter/material.dart';
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
        colorScheme: .fromSeed(seedColor: Colors.deepPurple, brightness: .light),
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
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      print("Counter is now $_counter");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: HStack(
          spacing: 10.0,
          [
            Text('Shark Budget', style: DefaultTextStyle.of(context).style.apply(color: AppColors.contentColorBlue, decoration: .none, fontSizeFactor: 0.5)),
            FittedBox(
              fit: BoxFit.contain, // otherwise the logo will be tiny
              child: Image.asset('images/shark_budget.jpg', width: 50, height: 50),
            )
          ]
        ),
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
                onPressed: _incrementCounter,
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
                child: HStack(
                  spacing: 20,
                  [
                    VStack(
                      [
                        Text('Total Income'),
                        Text('\$0.00', style: DefaultTextStyle.of(context).style.apply(color: Colors.black54, decorationStyle: .dashed, fontSizeFactor: 0.5)),
                        Text('+8% vs last period', style: DefaultTextStyle.of(context).style.apply(color: AppColors.contentColorGreen, decoration: .none, fontSizeFactor: 0.3)),
                      ],
                      crossAlignment: CrossAxisAlignment.start,
                      axisSize: MainAxisSize.min,
                    ),
                    VStack(
                      [
                        Text('Total Expenses'),
                        Text('\$1515.80', style: DefaultTextStyle.of(context).style.apply(color: Colors.black54, decorationStyle: .dashed, fontSizeFactor: 0.5)),
                        Text('+3% vs last period', style: DefaultTextStyle.of(context).style.apply(color: AppColors.contentColorGreen, decoration: .none, fontSizeFactor: 0.3)),
                      ],
                      crossAlignment: CrossAxisAlignment.start,
                      axisSize: MainAxisSize.min,
                    ),
                    VStack(
                      [
                        Text('Net Balance'),
                        Text('-\$1515.80', style: DefaultTextStyle.of(context).style.apply(color: Colors.black54, decorationStyle: .dashed, fontSizeFactor: 0.5)),
                        Text('Income – Expense', style: DefaultTextStyle.of(context).style.apply(color: Colors.black26, decoration: .none, fontSizeFactor: 0.3)),
                      ],
                      crossAlignment: CrossAxisAlignment.start,
                      axisSize: MainAxisSize.min,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Details
          VStack(
            [
              FloatingActionButton(
                onPressed: _incrementCounter,
                tooltip: 'Add Transaction',
                child: const Icon(Icons.add),
              ),
              TransactionCell(
                index: 0,
                transaction: Transaction(
                    "Date",
                    "Type",
                    "Category",
                    "Source/Merchant",
                    "Note",
                    "Amount"
                ),
                editable: false,
              ),
              TransactionCell(
                index: 1,
                transaction: Transaction(
                  "2 March 2026",
                  "Expense",
                  "Housing",
                  "Rent Payment",
                  "Monthly rent",
                  "\$1200.00"
                ),
              ),
              TransactionCell(
                index: 2,
                transaction: Transaction(
                    "3 March 2026",
                    "Expense",
                    "Food",
                    "Walmart",
                    "–",
                    "\$85.50"
                ),
              ),
              TransactionCell(
                index: 3,
                transaction: Transaction(
                    "3 March 2026",
                    "Expense",
                    "Transport",
                    "Gas Station",
                    "–",
                    "\$45.00"
                ),
              ),
            ]
          ),

          // Charts
          CashFlowLineChart(key: CashFlowLineChart.chartKey),

          // Settings
          Center(
            child: VStack(
              spacing: 20.0,
              [
                Icon(
                  Icons.settings,
                  color: Colors.deepPurple,
                  size: 30.0,
                ),
                Text('Settings and configuration options.')
              ]
            ),
          ),
        ],
      ),
    );
  }
}

/*
class _ContentTab extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContentTab({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
*/