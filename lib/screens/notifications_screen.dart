import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main.dart'; // للوصول إلى AppData و NotificationModel
import 'notification_chat_screen.dart'; // الشاشة الجديدة

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final isToday = now.year == dt.year && now.month == dt.month && now.day == dt.day;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'م' : 'ص';
    final timeString = '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';

    if (isToday) {
      return timeString;
    } else {
      return '${dt.year}/${dt.month}/${dt.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        backgroundColor: AppTheme.emeraldGreen,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: AppData.updateNotifier,
        builder: (context, _, __) {
          final allNotifications = AppData.notifications;

          if (allNotifications.isEmpty) {
            return const Center(
              child: Text("لا توجد إشعارات حتى الآن.", style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          // تجميع الإشعارات حسب رقم الهاتف
          final Map<String, List<NotificationModel>> grouped = {};
          for (var notif in allNotifications) {
            if (!grouped.containsKey(notif.customerPhone)) {
              grouped[notif.customerPhone] = [];
            }
            grouped[notif.customerPhone]!.add(notif);
          }

          // تحويلها إلى قائمة من المجموعات
          final groupedList = grouped.values.toList();
          
          // ترتيب المجموعات بحيث تظهر الأحدث في الأعلى (بناءً على آخر إشعار في المجموعة)
          groupedList.sort((a, b) {
            // نأخذ أول عنصر لأننا عند الإضافة نستخدم insert(0) فالأول هو الأحدث
            return b.first.timestamp.compareTo(a.first.timestamp);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: groupedList.length,
            itemBuilder: (context, index) {
              final group = groupedList[index];
              final latestNotif = group.first; // الأحدث

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    // فتح شاشة الشات الخاصة بهذا العميل
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationChatScreen(
                          customerPhone: latestNotif.customerPhone,
                          customerName: latestNotif.customerName,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.mintGreen,
                          child: Text(
                            latestNotif.customerName.isNotEmpty ? latestNotif.customerName[0].toUpperCase() : 'ع',
                            style: const TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      latestNotif.customerName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    _formatDateTime(latestNotif.timestamp),
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: AppTheme.emeraldGreen, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'آخر دفعة: ${latestNotif.amount} SAR',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                  ),
                                  const Spacer(),
                                  if (group.length > 1)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.emeraldGreen,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${group.length}',
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
