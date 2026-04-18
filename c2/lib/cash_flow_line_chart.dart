import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:c2/app_colors.dart';

class CashFlowChartData {
  final List<FlSpot> mainData;
  final List<FlSpot> avgData;

  //CashFlowChartData({required this.mainData, required this.avgData});

  static List<FlSpot> _processMainData(List<int> netCashFlow) {
    return netCashFlow.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.toDouble() / 100);
    }).toList();
  }

  static List<FlSpot> _processAvgData(
    List<int> netCashFlow,
    double avgCashFlow,
  ) {
    return netCashFlow.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), avgCashFlow / 100);
    }).toList();
  }

  CashFlowChartData(List<int> netCashFlow, double avgCashFlow)
    : mainData = _processMainData(netCashFlow),
      avgData = _processAvgData(netCashFlow, avgCashFlow);
}

final ValueNotifier<CashFlowChartData?> cashFlowNotifier = ValueNotifier(null);

class CashFlowLineChart extends StatefulWidget {
  const CashFlowLineChart({super.key});

  @override
  State<CashFlowLineChart> createState() => CashFlowLineChartState();
}

class CashFlowLineChartState extends State<CashFlowLineChart> {
  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CashFlowChartData?>(
      valueListenable: cashFlowNotifier,
      builder: (context, data, child) {
        return Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 2,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 24,
                  bottom: 12,
                ),
                child: data == null
                    ? const Center(child: CircularProgressIndicator())
                    : LineChart(
                        showAvg
                            ? avgData(data.avgData)
                            : mainData(data.mainData),
                      ),
              ),
            ),
            SizedBox(
              width: 60,
              height: 34,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showAvg = !showAvg;
                  });
                },
                child: Text(
                  'avg',
                  style: TextStyle(
                    fontSize: 12,
                    color: showAvg
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  LineChartData mainData(List<FlSpot> spots) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1000,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: -6000,
      maxY: 6000,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: const [
              AppColors.contentColorCyan,
              AppColors.contentColorBlue,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: const [
                AppColors.contentColorCyan,
                AppColors.contentColorBlue,
              ].map((color) => color.withValues(alpha: 0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData(List<FlSpot> spots) {
    final gradientColors = const [
      AppColors.contentColorCyan,
      AppColors.contentColorBlue,
    ];

    return LineChartData(
      lineTouchData: const LineTouchData(enabled: true),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1000,
        getDrawingVerticalLine: (value) {
          return const FlLine(color: Color(0xff37434d), strokeWidth: 1);
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Color(0xff37434d), strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: -6000,
      maxY: 6000,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(
                begin: gradientColors[0],
                end: gradientColors[1],
              ).lerp(0.2)!,
              ColorTween(
                begin: gradientColors[0],
                end: gradientColors[1],
              ).lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(
                  begin: gradientColors[0],
                  end: gradientColors[1],
                ).lerp(0.2)!.withValues(alpha: 0.1),
                ColorTween(
                  begin: gradientColors[0],
                  end: gradientColors[1],
                ).lerp(0.2)!.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    String text;
    switch (value.toInt()) {
      case 2:
        text = 'Jun 2025';
        break;
      case 5:
        text = 'Sep 2025';
        break;
      case 8:
        text = 'Dec 2025';
        break;
      case 11:
        text = 'Mar 2026';
        break;
      default:
        text = '';
    }
    return SideTitleWidget(
      meta: meta,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
    String text;
    switch (value.toInt()) {
      case -3000:
        text = '-3K';
        break;
      case 0:
        text = '0';
        break;
      case 3000:
        text = '3K';
        break;
      default:
        text = '';
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
