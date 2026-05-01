import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
// استيراد ملف main للوصول إلى AppData و InvoiceModel العالمي
import '../main.dart';

class UnpaidInvoicesScreen extends StatelessWidget {
  const UnpaidInvoicesScreen({super.key});

  // دالة إرسال رسالة واتساب للتذكير
  void _sendWhatsAppReminder(String phone, String name, String amount) async {
    String cleanPhone = phone.trim();
    // التأكد من إضافة مفتاح الدولة إذا لم يكن موجوداً
    if (!cleanPhone.startsWith('967')) {
      cleanPhone = '967$cleanPhone';
    }

    String message = "تحية طيبة أ/ $name، نذكركم بوجود مبلغ مستحق قدره $amount SAR لدى تطبيق منجز مالي. شكراً لتعاونكم.";

    var whatsappUrl = "whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}";

    try {
      Uri uri = Uri.parse(whatsappUrl);
      await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
    } catch (e) {
      var fallbackUrl = "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}";
      await launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('المستحقات غير المدفوعة'),
        centerTitle: true,
        backgroundColor: AppTheme.emeraldGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: AppData.updateNotifier,
        builder: (context, _, __) {
          // 1. جلب الفواتير غير المدفوعة فقط من المخزن العالمي
          final List<InvoiceModel> unpaidList = AppData.invoices.where((i) => !i.isPaid).toList();

          // 2. حساب إجمالي المبالغ المعلقة تلقائياً
          double totalPending = unpaidList.fold(0, (sum, item) => sum + item.amount);

          return Column(
            children: [
              // كرت إجمالي المبالغ المعلقة (يحدث تلقائياً)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 30),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.emeraldGreen,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.emeraldGreen.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text('إجمالي المبالغ المعلقة',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('${totalPending.toStringAsFixed(2)} SAR',
                        style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // قائمة الفواتير غير المدفوعة
              Expanded(
                child: unpaidList.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: unpaidList.length,
                  itemBuilder: (context, index) {
                    final inv = unpaidList[index];
                    return _buildInvoiceItem(
                      context,
                      name: inv.name,
                      date: inv.date,
                      amount: inv.amount.toString(),
                      phone: inv.phone,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // واجهة تظهر عند عدم وجود مستحقات
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green.withOpacity(0.3)),
          const SizedBox(height: 10),
          const Text("لا توجد مبالغ معلقة حالياً", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(BuildContext context, {required String name, required String date, required String amount, required String phone}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppTheme.mintGreen.withOpacity(0.15),
            child: const Icon(Icons.person_rounded, color: AppTheme.emeraldGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('التاريخ: $date', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(phone, style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$amount SAR',
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              ElevatedButton.icon(
                onPressed: () => _sendWhatsAppReminder(phone, name, amount),
                icon: const Icon(Icons.send_rounded, size: 14),
                label: const Text('تذكير'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}