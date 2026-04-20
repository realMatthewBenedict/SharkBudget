import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:c2/app_colors.dart';
import 'package:c2/indicator.dart';

class ExpenseReport {
  ExpenseReport(
    this.bills,
    this.food,
    this.housing,
    this.transport,
    this.other,
  );

  final int bills;
  final int food;
  final int housing;
  final int transport;
  final int other;

  List<double> toPercentages() {
    final total = bills + food + housing + transport + other;
    if (total == 0) {
      return [0, 0, 0, 0, 0];
    }
    return [
      bills * 100.0 / total,
      food * 100.0 / total,
      housing * 100.0 / total,
      transport * 100.0 / total,
      other * 100.0 / total,
    ];
  }
}

final ValueNotifier<List<double>> expensesNotifier =
    ValueNotifier<List<double>>(<double>[70, 10, 15, 5, 0]);

// ----- widget -----

class ExpensesPieChart extends StatefulWidget {
  const ExpensesPieChart({super.key});

  @override
  State<ExpensesPieChart> createState() => ExpensesPieChartState();
}

class ExpensesPieChartState extends State<ExpensesPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<double>>(
      valueListenable: expensesNotifier,
      builder: (context, valueData, child) {
        final data = valueData;

        return AspectRatio(
          aspectRatio: 1.3,
          child: Row(
            children: <Widget>[
              const SizedBox(height: 18),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: showingSections(data),
                    ),
                  ),
                ),
              ),
              const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Indicator(
                    color: AppColors.contentColorBlue,
                    text: 'Bills',
                    isSquare: true,
                  ),
                  SizedBox(height: 4),
                  Indicator(
                    color: AppColors.contentColorYellow,
                    text: 'Food',
                    isSquare: true,
                  ),
                  SizedBox(height: 4),
                  Indicator(
                    color: AppColors.contentColorGreen,
                    text: 'Housing',
                    isSquare: true,
                  ),
                  SizedBox(height: 4),
                  Indicator(
                    color: AppColors.contentColorRed,
                    text: 'Transport',
                    isSquare: true,
                  ),
                  SizedBox(height: 4),
                  Indicator(
                    color: AppColors.contentColorBlack,
                    text: 'Other',
                    isSquare: true,
                  ),
                  SizedBox(height: 18),
                ],
              ),
              const SizedBox(width: 28),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> showingSections(List<double> valueData) {
    return List.generate(5, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: AppColors.contentColorBlue,
            value: valueData[0],
            title: '${valueData[0].toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: AppColors.contentColorYellow,
            value: valueData[1],
            title: '${valueData[1].toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: AppColors.contentColorGreen,
            value: valueData[2],
            title: '${valueData[2].toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: AppColors.contentColorRed,
            value: valueData[3],
            title: '${valueData[3].toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );
        case 4:
          return PieChartSectionData(
            color: AppColors.contentColorBlack,
            value: valueData[4],
            title: '${valueData[4].toStringAsFixed(1)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.mainTextColor1,
              shadows: shadows,
            ),
          );
        default:
          throw StateError('Invalid section index $i');
      }
    });
  }
}
