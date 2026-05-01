import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main.dart'; // للوصول إلى NotificationModel

class NotificationChatScreen extends StatelessWidget {
  final String customerPhone;
  final String customerName;

  const NotificationChatScreen({
    super.key,
    required this.customerPhone,
    required this.customerName,
  });

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final isToday = now.year == dt.year && now.month == dt.month && now.day == dt.day;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'م' : 'ص';
    final timeString = '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';

    if (isToday) {
      return timeString;
    } else {
      return '${dt.year}/${dt.month}/${dt.day} - $timeString';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customerName),
        backgroundColor: AppTheme.emeraldGreen,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: AppData.updateNotifier,
        builder: (context, _, __) {
          // جلب إشعارات هذا العميل فقط وترتيبها من الأقدم للأحدث (مثل الشات)
          final customerNotifications = AppData.notifications
              .where((n) => n.customerPhone == customerPhone)
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

          if (customerNotifications.isEmpty) {
            return const Center(child: Text("لا توجد إشعارات لهذا العميل."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: customerNotifications.length,
            itemBuilder: (context, index) {
              final notif = customerNotifications[index];
              return Align(
                alignment: Alignment.centerLeft, // الإشعارات القادمة تظهر في اليسار أو اليمين حسب رغبتك
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15).copyWith(
                      bottomLeft: const Radius.circular(0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "تأكيد دفع جديد ✅",
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "تم دفع مبلغ ${notif.amount} SAR بنجاح.",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          _formatDateTime(notif.timestamp),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
