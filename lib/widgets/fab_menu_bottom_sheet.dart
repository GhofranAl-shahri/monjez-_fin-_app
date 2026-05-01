import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
// الاستيرادات الصحيحة والمنظمة لصفحات "مُنجز مالي"
import '../screens/CreateInvoiceScreen.dart';
import '../screens/my_invoices_screen.dart';
import '../screens/statistics_screen.dart'; // استيراد صفحة الإحصائيات الجديدة

class FABMenuBottomSheet extends StatelessWidget {
  const FABMenuBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ليأخذ حجم المحتوى فقط ويظهر كـ Bottom Sheet أنيق
        children: [
          // شريط السحب الصغير في الأعلى للتنسيق الجمالي
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const Text(
            'خيارات سريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.emeraldGreen,
            ),
          ),
          const SizedBox(height: 25),

          // صف الأزرار الثلاثة (التصميم الإبداعي القوي الذي اعتمدناه)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 1. زر إنشاء فاتورة
              _buildSquareButton(
                context,
                icon: Icons.post_add_rounded,
                title: 'إنشاء فاتورة',
                onTap: () {
                  Navigator.pop(context); // إغلاق القائمة السفلية أولاً
                  Navigator.pushNamed(context, '/create_invoice'); // الانتقال لصفحة الفورم
                },
              ),

              // 2. زر فواتيري (يحتوي على التقسيم الثلاثي: الكل، المدفوعة، غير المدفوعة)
              _buildSquareButton(
                context,
                icon: Icons.description_outlined,
                title: 'فواتيري',
                onTap: () {
                  Navigator.pop(context); // إغلاق القائمة السفلية أولاً
                  Navigator.pushNamed(context, '/my_invoices'); // الانتقال لصفحة الفواتير المنظمة
                },
              ),

              // 3. زر الإحصائيات (الذكاء المالي وتحليل العملاء)
              _buildSquareButton(
                context,
                icon: Icons.auto_graph_rounded,
                title: 'الإحصائيات',
                onTap: () {
                  Navigator.pop(context); // إغلاق القائمة السفلية أولاً
                  // التعديل هنا: الربط بالمسار الجديد للصفحة المستقلة
                  Navigator.pushNamed(context, '/statistics');
                },
              ),
            ],
          ),
          const SizedBox(height: 30), // مسافة أمان سفلية لضمان ظهور المحتوى بشكل مريح
        ],
      ),
    );
  }

  // دالة بناء المربعات (التصميم الاحترافي بلمسة الـ Mint Green)
  Widget _buildSquareButton(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: AppTheme.mintGreen.withOpacity(0.15), // خلفية فاتحة وراقية
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.1)),
            ),
            child: Icon(
              icon,
              color: AppTheme.emeraldGreen,
              size: 35,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.emeraldGreen,
          ),
        ),
      ],
    );
  }
}