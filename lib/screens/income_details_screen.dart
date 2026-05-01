import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class IncomeDetailsScreen extends StatelessWidget {
  const IncomeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("إجمالي الدخل"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.emeraldGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان والمبلغ الإجمالي بدون كلمة "الشهر"
            const Text("إجمالي الدخل العام", style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text(
              "4,850.00\$", // القيمة الكلية بالدولار
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen),
            ),

            const SizedBox(height: 40),

            // المخطط البياني المعدل
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    // إعدادات المحور الجانبي (التزايد بـ 50$)
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 50, // التزايد كل 50 دولار
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Text("${value.toInt()}\$", style: const TextStyle(fontSize: 10, color: Colors.grey));
                        },
                      ),
                    ),
                    // إعدادات المحور السفلي (الأشهر 1-12)
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1, // إظهار كل شهر
                        getTitlesWidget: (value, meta) {
                          if (value >= 1 && value <= 12) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 1,
                  maxX: 12,
                  minY: 0,
                  maxY: 500, // أقصى حد للتزايد في المخطط
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 100),
                        FlSpot(2, 150),
                        FlSpot(3, 120),
                        FlSpot(4, 300),
                        FlSpot(5, 450), // أعلى دخل في شهر 5
                        FlSpot(6, 250),
                        FlSpot(7, 350),
                        FlSpot(8, 200),
                        FlSpot(9, 400),
                        FlSpot(10, 300),
                        FlSpot(11, 450),
                        FlSpot(12, 480),
                      ],
                      isCurved: true,
                      color: AppTheme.emeraldGreen,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.emeraldGreen.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

            // قسم أعلى دخل في الشهر (تصميم مُنجز)
            const Text("تحليل الأداء", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.emeraldGreen,
                    child: const Icon(Icons.trending_up, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("أعلى دخل شهري", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("تم تحقيقه في شهر ديسمبر (12)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Text(
                    "480.00\$",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}