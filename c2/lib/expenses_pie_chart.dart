import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:c2/app_colors.dart';
import 'package:c2/indicator.dart';

class ExpenseReport {
  ExpenseReport(this.bills, this.food, this.housing, this.transport, this.other);

  int bills;
  int food;
  int housing;
  int transport;
  int other;
}

class ExpensesPieChart extends StatefulWidget {
  static final GlobalKey<ExpensesPieChartState> chartKey = GlobalKey<ExpensesPieChartState>();
  const ExpensesPieChart({super.key});

  @override
  State<StatefulWidget> createState() => ExpensesPieChartState();
}

class ExpensesPieChartState extends State {
  int touchedIndex = -1;

  List<double> valueData = [70, 10, 15, 5, 0];

  void updateData(List<double> newValueData) {
    setState(() {
      valueData = newValueData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
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
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
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
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: AppColors.contentColorYellow,
                text: 'Food',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: AppColors.contentColorGreen,
                text: 'Housing',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: AppColors.contentColorRed,
                text: 'Transport',
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: AppColors.contentColorBlack,
                text: 'Other',
                isSquare: true,
              ),
              SizedBox(
                height: 18,
              ),
            ],
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return switch (i) {
        0 => PieChartSectionData(
          color: AppColors.contentColorBlue,
          value: valueData[0],
          title: '${valueData[0]}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.mainTextColor1,
            shadows: shadows,
          ),
        ),
        1 => PieChartSectionData(
          color: AppColors.contentColorYellow,
          value: valueData[1],
          title: '${valueData[1]}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.mainTextColor1,
            shadows: shadows,
          ),
        ),
        2 => PieChartSectionData(
          color: AppColors.contentColorGreen,
          value: valueData[2],
          title: '${valueData[2]}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.mainTextColor1,
            shadows: shadows,
          ),
        ),
        3 => PieChartSectionData(
          color: AppColors.contentColorRed,
          value: valueData[3],
          title: '${valueData[3]}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.mainTextColor1,
            shadows: shadows,
          ),
        ),
        4 => PieChartSectionData(
          color: AppColors.contentColorBlack,
          value: valueData[4],
          title: '${valueData[4]}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.mainTextColor1,
            shadows: shadows,
          ),
        ),
        _ => throw StateError('Invalid'),
      };
    });
  }
}
