import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../main.dart'; // تأكد من استيراد الملف الذي يحتوي على AppData و InvoiceModel

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  // --- دالة تحليل وتصنيف العملاء آلياً بناءً على عدد الطلبات ---
  Map<String, List<Map<String, String>>> _getAutoClassifiedCustomers() {
    Map<String, int> customerCounts = {};

    // حساب عدد فواتير كل عميل
    for (var invoice in AppData.invoices) {
      customerCounts[invoice.name] = (customerCounts[invoice.name] ?? 0) + 1;
    }

    List<Map<String, String>> vip = [];
    List<Map<String, String>> medium = [];
    List<Map<String, String>> rare = [];

    customerCounts.forEach((name, count) {
      final data = {"name": name, "info": "$count طلبات"};
      if (count >= 3) {
        vip.add(data);
      } else if (count == 2) {
        medium.add(data);
      } else if (count == 1) {
        rare.add(data);
      }
    });

    return {"vip": vip, "medium": medium, "rare": rare};
  }

  // --- دالة توليد نقاط المخطط البياني بناءً على مبالغ الفواتير الفعلية ---
  List<FlSpot> _generateLiveSpots() {
    // ننشئ خريطة لتوزيع المبالغ على أشهر السنة (من 1 إلى 12)
    Map<int, double> monthlySums = {for (var i = 1; i <= 12; i++) i: 0.0};

    for (var invoice in AppData.invoices) {
      if (invoice.isPaid) {
        try {
          // استخراج الشهر من صيغة التاريخ "2026/04/28"
          int month = int.parse(invoice.date.split('/')[1]);
          monthlySums[month] = (monthlySums[month] ?? 0) + invoice.amount;
        } catch (e) {
          // في حال كان تنسيق التاريخ مختلفاً
        }
      }
    }

    // تحويل البيانات لنقاط في المخطط (X هو الشهر، Y هو المبلغ)
    // ملاحظة: قمنا بتقسيم المبلغ على 1000 لجعل المخطط متناسقاً بصرياً
    return monthlySums.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value / 1000))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // حساب الأرقام الفعلية من القائمة
    final totalCount = AppData.invoices.length;
    final paidCount = AppData.invoices.where((i) => i.isPaid).length;
    final unpaidCount = AppData.invoices.where((i) => !i.isPaid).length;
    final totalAmount = AppData.invoices.fold(0.0, (sum, item) => sum + item.amount);

    final classifiedCustomers = _getAutoClassifiedCustomers();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text("الإحصائيات المالية", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.emeraldGreen,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- القسم العلوي: الملخص السريع (بيانات حقيقية) ---
            const Text("ملخص الحالات", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard("الكل", totalCount.toString(), Icons.description_outlined, Colors.blue),
                _buildStatCard("مدفوعة", paidCount.toString(), Icons.check_circle_outline, Colors.green),
                _buildStatCard("غير مدفوعة", unpaidCount.toString(), Icons.pending_actions_rounded, Colors.red),
                _buildStatCard("الإجمالي العام", "${totalAmount.toStringAsFixed(0)} SAR", Icons.payments_outlined, AppTheme.emeraldGreen),
              ],
            ),

            const SizedBox(height: 30),

            // --- القسم الأوسط: مخطط النمو التلقائي ---
            const Text("نمو النشاط المالي (مبالغ الفواتير المدفوعة)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
            const SizedBox(height: 15),
            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 == 0 && value >= 1 && value <= 12) {
                            return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey));
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateLiveSpots(), // ربط حقيقي بالبيانات
                      isCurved: true,
                      color: AppTheme.emeraldGreen,
                      barWidth: 4,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: AppTheme.emeraldGreen.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- القسم السفلي: تصنيف العملاء الآلي بناءً على التكرار ---
            const Text("تصنيف العملاء (تحديث آلي)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
            const SizedBox(height: 15),

            if (totalCount == 0)
              const Center(child: Text("لا توجد فواتير لتصنيف العملاء بعد", style: TextStyle(color: Colors.grey))),

            if (classifiedCustomers['vip']!.isNotEmpty)
              _buildCustomerList("عملاء VIP (3 طلبات فما فوق)", classifiedCustomers['vip']!, Colors.amber),

            if (classifiedCustomers['medium']!.isNotEmpty)
              _buildCustomerList("عملاء متوسطون (طلبان)", classifiedCustomers['medium']!, Colors.blueGrey),

            if (classifiedCustomers['rare']!.isNotEmpty)
              _buildCustomerList("عملاء نادرون (طلب واحد)", classifiedCustomers['rare']!, Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          FittedBox(child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCustomerList(String title, List<Map<String, String>> data, Color tagColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        ...data.map((c) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFF0F4F8), child: Icon(Icons.person, size: 20, color: AppTheme.emeraldGreen)),
            title: Text(c['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            trailing: Text(c['info']!, style: const TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        )).toList(),
      ],
    );
  }
}